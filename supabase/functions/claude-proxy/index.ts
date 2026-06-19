// claude-proxy — Edge Function
// Proxies Claude API calls so the Anthropic key never lives on the device.
// Requires ANTHROPIC_API_KEY set as a Supabase secret.
// Hardened: model allowlist, max_tokens cap, tightened CORS, per-IP rate limit.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ALLOWED_MODELS = new Set([
  "claude-haiku-4-5-20251001",
  "claude-sonnet-4-6",
]);
const MAX_TOKENS_CAP = 1500;

// Native app only — no browser front-end needs this. Keep headers minimal.
const CORS = {
  "Access-Control-Allow-Origin": "https://twinflameunion.app",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status: number) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) return json({ error: "ANTHROPIC_API_KEY not configured" }, 500);

  let payload: any;
  try {
    payload = await req.json();
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }

  const { model, max_tokens, system, messages, stream } = payload ?? {};

  if (typeof model !== "string" || !ALLOWED_MODELS.has(model)) {
    return json({ error: "Model not allowed" }, 400);
  }
  if (!Array.isArray(messages) || messages.length === 0) {
    return json({ error: "messages required" }, 400);
  }
  const cappedTokens = Math.min(Number(max_tokens) || 300, MAX_TOKENS_CAP);

  // Abuse controls. The anon key ships inside the app binary, so these caps — not
  // the key — are what protect the paid Anthropic account. They FAIL CLOSED: if the
  // limiter backend is unavailable, or the platform gives no client IP, we refuse
  // the request rather than forward it to the paid upstream.
  const ip = (req.headers.get("x-forwarded-for") ?? "").split(",")[0].trim();
  if (!ip) {
    return json({ error: "Request origin could not be verified." }, 400);
  }
  try {
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Hard global daily ceiling — a backstop against a leaked anon key draining the
    // Anthropic budget even from many IPs. Tune p_max_per_day to your budget.
    const { data: underGlobal, error: gErr } = await admin.rpc(
      "check_proxy_under_global_cap",
      { p_max_per_day: 5000 },
    );
    if (gErr || underGlobal === false) {
      if (gErr) console.error("global-cap check failed:", gErr.message);
      return json({ error: "Service temporarily unavailable. Please try again shortly." }, 503);
    }

    // Per-IP rate limit (this call also records the hit).
    const { data: underLimit, error: rlErr } = await admin.rpc("check_proxy_rate", { p_ip: ip });
    if (rlErr) {
      console.error("rate-limit check failed:", rlErr.message);
      return json({ error: "Service temporarily unavailable. Please try again shortly." }, 503);
    }
    if (underLimit === false) {
      return json({ error: "Rate limit exceeded. Try again shortly." }, 429);
    }
  } catch (e) {
    // Fail closed: never forward to the paid upstream when the limiter is down.
    console.error("rate-limit unavailable:", e);
    return json({ error: "Service temporarily unavailable. Please try again shortly." }, 503);
  }

  const upstream = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({ model, max_tokens: cappedTokens, system, messages, stream: stream ?? false }),
  });

  // Pass through the response (handles both streaming and non-streaming)
  return new Response(upstream.body, {
    status: upstream.status,
    headers: {
      ...CORS,
      "Content-Type": upstream.headers.get("Content-Type") ?? "application/json",
    },
  });
});
