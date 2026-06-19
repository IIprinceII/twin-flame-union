//
//  ConnectView.swift
//  Twin Flame Union
//
//  "Connect with your Twin Flame" — invite code generation + QR + accept flow.
//  Governing Deities: Eros · Harmonia
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - ConnectView

struct ConnectView: View {

    // MARK: - State

    @State private var pairing: Pairing?
    @State private var isLoading      = false
    @State private var errorMessage: String?
    @State private var codeInput      = ""
    @State private var showCopied     = false
    @State private var appeared       = false

    @AppStorage("activePairingId") private var activePairingId: String = ""

    // MARK: - Body

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            // Eros rose glow
            RadialGradient(
                colors: [AppColors.rose.opacity(0.08), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()
            .accessibilityHidden(true)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Deity Banner
                    erosBanner
                        .padding(.top, 8)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)

                    if isLoading {
                        loadingState
                    } else if let p = pairing, p.isActive {
                        connectedState(pairing: p)
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    } else if let p = pairing {
                        // Invite created, awaiting partner
                        pendingState(pairing: p)
                            .transition(.opacity)
                    } else {
                        // No pairing yet
                        unpairedState
                            .transition(.opacity)
                    }

                    if let err = errorMessage {
                        errorBubble(err)
                    }

                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 24)
                .animation(.easeInOut(duration: 0.4), value: pairing?.id)
                .animation(.easeInOut(duration: 0.3), value: isLoading)
            }
        }
        .navigationTitle("Twin Flame Connection")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .task { await loadPairing() }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
        }
    }

    // MARK: - Eros Banner

    private var erosBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        colors: [AppColors.rose.opacity(0.45), AppColors.rose.opacity(0.08)],
                        center: .center, startRadius: 0, endRadius: 26
                    ))
                    .frame(width: 52, height: 52)
                Circle()
                    .strokeBorder(AppColors.rose.opacity(0.35), lineWidth: 1)
                    .frame(width: 52, height: 52)
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.rose)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("SACRED BOND · EROS · HARMONIA")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .tracking(2.0)
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
                Text("Connect with your Twin Flame")
                    .font(AppFont.serifTitle(17))
                    .foregroundStyle(AppColors.cream)
                Text("Eros weaves the golden thread between souls.")
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.6))
                    .italic()
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Sacred Bond. Governed by Eros and Harmonia. Connect with your Twin Flame.")
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(AppColors.rose)
                .scaleEffect(1.3)
            Text("Consulting the sacred records…")
                .font(AppFont.body(14))
                .foregroundStyle(AppColors.lavender)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Unpaired State

    private var unpairedState: some View {
        VStack(spacing: 24) {
            // Create bond button
            sacredCard {
                VStack(spacing: 18) {
                    Image(systemName: "link")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColors.rose)
                        .accessibilityHidden(true)

                    VStack(spacing: 6) {
                        Text("Create Our Sacred Bond")
                            .font(AppFont.serifHeadline(20))
                            .foregroundStyle(AppColors.cream)
                        Text("Generate an invite code and share it with\nyour twin flame to join you.")
                            .font(AppFont.body(14))
                            .foregroundStyle(AppColors.lavender)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        HapticManager.impact(.medium)
                        Task { await createInvite() }
                    } label: {
                        Text("Create our sacred bond")
                            .modifier(PrimaryAuthButton())
                    }
                    .disabled(isLoading)
                }
                .padding(24)
            }

            // Divider
            HStack {
                Rectangle().fill(AppColors.purple.opacity(0.3)).frame(height: 1)
                Text("or")
                    .font(AppFont.caption(13))
                    .foregroundStyle(AppColors.lavender.opacity(0.5))
                    .padding(.horizontal, 12)
                Rectangle().fill(AppColors.purple.opacity(0.3)).frame(height: 1)
            }

            // Accept invite
            acceptCodeCard
        }
    }

    // MARK: - Accept Code Card

    private var acceptCodeCard: some View {
        sacredCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Enter Their Code")
                    .font(AppFont.serifTitle(16))
                    .foregroundStyle(AppColors.cream)
                Text("Your twin flame shared an 8-character code with you.")
                    .font(AppFont.caption(13))
                    .foregroundStyle(AppColors.lavender)

                TextField("e.g. ABC23456", text: $codeInput)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    .foregroundStyle(AppColors.cream)
                    .tint(AppColors.rose)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(AppColors.rose.opacity(0.35), lineWidth: 1)
                    )
                    .accessibilityLabel("Invite code entry")

                Button {
                    HapticManager.impact(.medium)
                    Task { await acceptInvite() }
                } label: {
                    Text("Join our union")
                        .modifier(PrimaryAuthButton(isEnabled: codeInput.count >= 6))
                }
                .disabled(codeInput.count < 6 || isLoading)
            }
            .padding(24)
        }
    }

    // MARK: - Pending State (invite created, awaiting partner)

    private func pendingState(pairing: Pairing) -> some View {
        VStack(spacing: 24) {
            sacredCard {
                VStack(spacing: 20) {
                    Text("Share This Sacred Code")
                        .font(AppFont.serifHeadline(20))
                        .foregroundStyle(AppColors.cream)

                    Text("Share this with your twin flame.\nThey enter it to join your sacred union.")
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)

                    // Big invite code
                    Text(pairing.inviteCode)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppColors.gold)
                        .tracking(6)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 28)
                        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(AppColors.gold.opacity(0.25), lineWidth: 1)
                        )
                        .accessibilityLabel("Your invite code: \(pairing.inviteCode.map(String.init).joined(separator: " "))")

                    // QR Code
                    if let qrImage = generateQR(from: pairing.inviteCode) {
                        VStack(spacing: 8) {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .padding(12)
                                .background(.white, in: RoundedRectangle(cornerRadius: 12))
                                .accessibilityLabel("QR code for invite code \(pairing.inviteCode)")

                            Text("Scan to connect")
                                .font(AppFont.caption(12))
                                .foregroundStyle(AppColors.lavender.opacity(0.6))
                                .italic()
                        }
                    }

                    // Copy + Share buttons
                    HStack(spacing: 14) {
                        Button {
                            UIPasteboard.general.string = pairing.inviteCode
                            HapticManager.notification(.success)
                            withAnimation { showCopied = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showCopied = false }
                            }
                        } label: {
                            Label(showCopied ? "Copied!" : "Copy code",
                                  systemImage: showCopied ? "checkmark" : "doc.on.doc")
                                .font(AppFont.body(14, weight: .semibold))
                                .foregroundStyle(showCopied ? AppColors.sage : AppColors.cream)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1)
                                )
                        }
                        .accessibilityLabel(showCopied ? "Copied to clipboard" : "Copy invite code")

                        ShareLink(item: "Join my Twin Flame Union! Enter code: \(pairing.inviteCode)") {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(AppFont.body(14, weight: .semibold))
                                .foregroundStyle(AppColors.cream)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(AppColors.purple.opacity(0.4), lineWidth: 1)
                                )
                        }
                    }

                    Text("Awaiting your twin flame…")
                        .font(AppFont.caption(12))
                        .foregroundStyle(AppColors.lavender.opacity(0.5))
                        .italic()
                }
                .padding(24)
            }

            // Also allow accepting in case roles are reversed
            sacredCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Or Enter Their Code")
                        .font(AppFont.serifTitle(16))
                        .foregroundStyle(AppColors.cream)

                    TextField("e.g. ABC23456", text: $codeInput)
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                        .foregroundStyle(AppColors.cream)
                        .tint(AppColors.rose)
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(AppColors.rose.opacity(0.35), lineWidth: 1)
                        )

                    Button {
                        HapticManager.impact(.medium)
                        Task { await acceptInvite() }
                    } label: {
                        Text("Join our union")
                            .modifier(PrimaryAuthButton(isEnabled: codeInput.count >= 6))
                    }
                    .disabled(codeInput.count < 6 || isLoading)
                }
                .padding(24)
            }
        }
    }

    // MARK: - Connected State

    private func connectedState(pairing: Pairing) -> some View {
        sacredCard {
            VStack(spacing: 22) {
                // Sacred glow ring
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [AppColors.rose.opacity(0.35), Color.clear],
                            center: .center, startRadius: 0, endRadius: 60
                        ))
                        .frame(width: 120, height: 120)
                    Circle()
                        .strokeBorder(AppColors.gold.opacity(0.4), lineWidth: 1.5)
                        .frame(width: 100, height: 100)
                    Image(systemName: "infinity")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.gold)
                        .accessibilityHidden(true)
                }
                .padding(.top, 8)

                VStack(spacing: 8) {
                    Text("Connected")
                        .font(AppFont.serifHeadline(28))
                        .foregroundStyle(AppColors.cream)
                    Text("✨")
                        .font(.system(size: 28))
                        .accessibilityHidden(true)
                    Text("Your twin flame bond has been sealed.\nEros and Harmonia bless your sacred union.")
                        .font(AppFont.body(15))
                        .foregroundStyle(AppColors.lavender)
                        .multilineTextAlignment(.center)
                        .italic()
                }

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(AppColors.sage)
                        .accessibilityHidden(true)
                    Text("Bond active")
                        .font(AppFont.body(14, weight: .semibold))
                        .foregroundStyle(AppColors.sage)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(AppColors.sage.opacity(0.12), in: Capsule())
                .overlay(Capsule().strokeBorder(AppColors.sage.opacity(0.3), lineWidth: 1))
                .accessibilityLabel("Bond active")
                .padding(.bottom, 8)
            }
            .padding(28)
        }
    }

    // MARK: - Error Bubble

    private func errorBubble(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppColors.ember)
                .font(.system(size: 16))
                .accessibilityHidden(true)
            Text(message)
                .font(AppFont.body(13))
                .foregroundStyle(AppColors.cream)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(AppColors.ember.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppColors.ember.opacity(0.3), lineWidth: 1)
        )
        .accessibilityLabel("Error: \(message)")
    }

    // MARK: - Sacred Card Container

    @ViewBuilder
    private func sacredCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity)
            .background(AppColors.deepViolet.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(AppColors.purple.opacity(0.35), lineWidth: 1)
            )
    }

    // MARK: - QR Generator (CoreImage, no external dependencies)

    private func generateQR(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.correctionLevel = "M"
        guard let data = string.data(using: .utf8) else { return nil }
        filter.message = data
        guard let output = filter.outputImage else { return nil }
        let scale = CGAffineTransform(scaleX: 10, y: 10)
        let scaled = output.transformed(by: scale)
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    // MARK: - Actions

    private func loadPairing() async {
        isLoading = true
        errorMessage = nil
        do {
            pairing = try await PairingService.myPairing()
        } catch SupabaseError.anonymousProviderDisabled {
            errorMessage = SupabaseError.anonymousProviderDisabled.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func createInvite() async {
        isLoading = true
        errorMessage = nil
        do {
            pairing = try await PairingService.createInvite()
        } catch SupabaseError.anonymousProviderDisabled {
            errorMessage = SupabaseError.anonymousProviderDisabled.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func acceptInvite() async {
        let code = codeInput.trimmingCharacters(in: .whitespaces).uppercased()
        guard !code.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            pairing = try await PairingService.acceptInvite(code: code)
        } catch SupabaseError.invalidOrTakenCode {
            errorMessage = "That code is invalid or has already been used. Ask your twin flame to share a fresh one."
        } catch SupabaseError.anonymousProviderDisabled {
            errorMessage = SupabaseError.anonymousProviderDisabled.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
