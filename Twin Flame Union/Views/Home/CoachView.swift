//
//  CoachView.swift
//  Twin Flame Union
//
//  AI Love Coach with free tier and premium paywall.
//

import SwiftUI
import StoreKit

// MARK: - Coach ViewModel

@Observable
@MainActor
final class CoachViewModel {

    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isStreaming: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var showPaywall: Bool = false

    @ObservationIgnored
    private let service = LoveCoachService()

    @ObservationIgnored
    private let maxFreeMessagesPerDay = 5

    // Stored in UserDefaults manually (not @AppStorage since @Observable)
    private let freeCountKey = "coachFreeMessageCount"
    private let freeDateKey  = "coachFreeMessageDate"

    var freeMessagesUsed: Int {
        get { resetIfNewDay(); return UserDefaults.standard.integer(forKey: freeCountKey) }
        set { UserDefaults.standard.set(newValue, forKey: freeCountKey) }
    }

    var freeMessagesRemaining: Int {
        guard !StoreService.shared.isPremium else { return Int.max }
        return max(0, maxFreeMessagesPerDay - freeMessagesUsed)
    }

    var canSendMessage: Bool {
        StoreService.shared.isPremium || freeMessagesUsed < maxFreeMessagesPerDay
    }

    private func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = UserDefaults.standard.object(forKey: freeDateKey) as? Date {
            let lastDay = Calendar.current.startOfDay(for: last)
            if lastDay < today {
                UserDefaults.standard.set(0, forKey: freeCountKey)
                UserDefaults.standard.set(today, forKey: freeDateKey)
            }
        } else {
            UserDefaults.standard.set(today, forKey: freeDateKey)
        }
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming else { return }

        guard canSendMessage else {
            showPaywall = true
            return
        }

        inputText = ""
        messages.append(ChatMessage(role: .user, content: text))

        if !StoreService.shared.isPremium {
            resetIfNewDay()
            freeMessagesUsed += 1
            UserDefaults.standard.set(Date(), forKey: freeDateKey)
        }

        let placeholder = ChatMessage(role: .assistant, content: "")
        messages.append(placeholder)
        let idx = messages.count - 1

        isStreaming = true
        errorMessage = nil

        let history = Array(messages.dropLast())

        do {
            for try await chunk in service.streamMessage(history: history) {
                messages[idx].content += chunk
            }
        } catch {
            messages[idx].content = "Something interrupted our connection. Please try again, dear soul."
            errorMessage = error.localizedDescription
            showError = true
        }

        isStreaming = false
    }
}

// MARK: - Coach View

struct CoachView: View {
    @State private var viewModel = CoachViewModel()
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            CosmicBackground()

            VStack(spacing: 0) {
                // Free tier banner
                if !StoreService.shared.isPremium {
                    FreeTierBanner(
                        remaining: viewModel.freeMessagesRemaining,
                        onUpgrade: { viewModel.showPaywall = true }
                    )
                }

                // Messages
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 14) {
                            if viewModel.messages.isEmpty {
                                CoachIntroCard()
                                    .padding(.top, 20)
                            }

                            ForEach(viewModel.messages) { message in
                                CoachMessageBubble(message: message)
                                    .id(message.id)
                            }

                            if viewModel.isStreaming && viewModel.messages.last?.content.isEmpty == true {
                                CoachTypingIndicator()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: viewModel.messages.count) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            if let lastId = viewModel.messages.last?.id {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages.last?.content) {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }

                // Input Bar
                CoachInputBar(
                    text: $viewModel.inputText,
                    isFocused: $inputFocused,
                    isStreaming: viewModel.isStreaming,
                    canSend: viewModel.canSendMessage
                ) {
                    Task { await viewModel.sendMessage() }
                }
            }
        }
        .navigationTitle("AI Love Coach")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .alert("Connection Lost", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Please try again.")
        }
        .sheet(isPresented: $viewModel.showPaywall) {
            PaywallSheet()
        }
        .onTapGesture { inputFocused = false }
    }
}

// MARK: - Free Tier Banner

private struct FreeTierBanner: View {
    let remaining: Int
    let onUpgrade: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.gold)

            Text(remaining > 0
                 ? "\(remaining) free message\(remaining == 1 ? "" : "s") remaining today"
                 : "Daily limit reached")
                .font(AppFont.caption(13))
                .foregroundStyle(AppColors.cream)

            Spacer()

            Button(action: onUpgrade) {
                Text("Upgrade")
                    .font(AppFont.caption(12, weight: .semibold))
                    .foregroundStyle(AppColors.deepViolet)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(AppColors.gold, in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppColors.deepViolet.opacity(0.9))
        .overlay(Rectangle().fill(AppColors.purple.opacity(0.2)).frame(height: 1), alignment: .bottom)
    }
}

// MARK: - Intro Card

private struct CoachIntroCard: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.purple.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .blur(radius: 12)
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(AppGradients.warm)
            }

            VStack(spacing: 8) {
                Text("I'm Luna ✨")
                    .font(AppFont.serifHeadline(24))
                    .foregroundStyle(AppColors.cream)

                Text("Your Twin Flame Love Coach")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.gold)

                Text("Share what's on your heart and I'll guide you through your journey with love and wisdom.")
                    .font(AppFont.body(14))
                    .foregroundStyle(AppColors.lavender)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(AppColors.deepViolet.opacity(0.6), in: RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 8)
    }
}

// MARK: - Message Bubble

private struct CoachMessageBubble: View {
    let message: ChatMessage
    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isUser { Spacer(minLength: 50) }

            if !isUser {
                ZStack {
                    Circle()
                        .fill(AppColors.purple.opacity(0.3))
                        .frame(width: 32, height: 32)
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.gold)
                }
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content.isEmpty ? " " : message.content)
                    .font(AppFont.body(15))
                    .foregroundStyle(AppColors.cream)
                    .lineSpacing(4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isUser
                            ? AnyShapeStyle(AppGradients.warm)
                            : AnyShapeStyle(AppColors.deepViolet.opacity(0.8)),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                isUser ? Color.clear : AppColors.purple.opacity(0.3),
                                lineWidth: 1
                            )
                    )

                Text(message.timestamp, style: .time)
                    .font(AppFont.caption(11))
                    .foregroundStyle(AppColors.lavender.opacity(0.6))
            }

            if !isUser { Spacer(minLength: 50) }
        }
    }
}

// MARK: - Typing Indicator

private struct CoachTypingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ZStack {
                Circle()
                    .fill(AppColors.purple.opacity(0.3))
                    .frame(width: 32, height: 32)
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.gold)
            }

            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(AppColors.lavender)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == i ? 1.3 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15),
                            value: phase
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.deepViolet.opacity(0.8), in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
            )

            Spacer(minLength: 50)
        }
        .onAppear { phase = 1 }
    }
}

// MARK: - Input Bar

private struct CoachInputBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let isStreaming: Bool
    let canSend: Bool
    let onSend: () -> Void

    private var isSendDisabled: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isStreaming
    }

    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask Luna anything...", text: $text, axis: .vertical)
                .font(AppFont.body(15))
                .foregroundStyle(AppColors.cream)
                .tint(AppColors.gold)
                .lineLimit(1...4)
                .focused(isFocused)
                .onSubmit { if !isStreaming { onSend() } }

            Button(action: onSend) {
                Image(systemName: isStreaming ? "ellipsis" : "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        isSendDisabled ? AppColors.lavender.opacity(0.4) : AppColors.gold
                    )
            }
            .disabled(isSendDisabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            AppColors.deepViolet.opacity(0.95)
                .overlay(
                    Rectangle()
                        .fill(AppColors.purple.opacity(0.2))
                        .frame(height: 1),
                    alignment: .top
                )
        )
    }
}

// MARK: - Paywall Sheet

struct PaywallSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storeService = StoreService.shared

    private let features = [
        ("Unlimited AI coaching sessions", "sparkles"),
        ("Deep spiritual guidance anytime", "moon.stars.fill"),
        ("Priority support from Luna", "heart.fill"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppGradients.cosmic.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {

                        // Hero
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.purple.opacity(0.3))
                                    .frame(width: 100, height: 100)
                                    .blur(radius: 16)
                                Image(systemName: "sparkles")
                                    .font(.system(size: 44))
                                    .foregroundStyle(AppGradients.warm)
                            }

                            Text("Unlock Luna ✨")
                                .font(AppFont.serifHeadline(30))
                                .foregroundStyle(AppColors.cream)

                            Text("Receive unlimited guidance from your\npersonal twin flame love coach.")
                                .font(AppFont.body(16))
                                .foregroundStyle(AppColors.lavender)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.top, 12)

                        // Feature bullets
                        VStack(spacing: 14) {
                            ForEach(features, id: \.0) { feature, icon in
                                HStack(spacing: 14) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(AppColors.gold)
                                    Text(feature)
                                        .font(AppFont.body(15))
                                        .foregroundStyle(AppColors.cream)
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.vertical, 24)
                        .background(AppColors.deepViolet.opacity(0.5), in: RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(AppColors.purple.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)

                        // Product buttons
                        VStack(spacing: 14) {
                            if storeService.isLoading {
                                ProgressView()
                                    .tint(AppColors.gold)
                                    .scaleEffect(1.2)
                                    .padding(.vertical, 20)
                            } else {
                                ForEach(storeService.products, id: \.id) { product in
                                    ProductButton(product: product) {
                                        Task {
                                            do {
                                                try await storeService.purchase(product)
                                                if storeService.isPremium { dismiss() }
                                            } catch { }
                                        }
                                    }
                                }

                                if storeService.products.isEmpty {
                                    Text("Products unavailable. Please try again.")
                                        .font(AppFont.body(14))
                                        .foregroundStyle(AppColors.lavender)
                                        .multilineTextAlignment(.center)
                                        .padding(.vertical, 10)
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Restore
                        Button {
                            Task {
                                await storeService.restore()
                                if storeService.isPremium { dismiss() }
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(AppFont.body(14))
                                .foregroundStyle(AppColors.lavender)
                                .underline()
                        }
                        .padding(.bottom, 12)
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(AppColors.lavender.opacity(0.6))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .preferredColorScheme(.dark)
        }
        .onAppear {
            if storeService.products.isEmpty {
                Task { await storeService.loadProducts() }
            }
        }
    }
}

// MARK: - Product Button

private struct ProductButton: View {
    let product: Product
    let action: () -> Void

    private var isAnnual: Bool { product.id.contains("annual") }

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(AppFont.body(16, weight: .semibold))
                            .foregroundStyle(AppColors.cream)

                        if isAnnual {
                            Text("Best Value")
                                .font(AppFont.caption(11, weight: .semibold))
                                .foregroundStyle(AppColors.deepViolet)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppColors.gold, in: Capsule())
                        }
                    }

                    if let subscription = product.subscription {
                        Text(subscriptionDescription(subscription))
                            .font(AppFont.caption(13))
                            .foregroundStyle(AppColors.lavender)
                    }
                }

                Spacer()

                Text(product.displayPrice)
                    .font(AppFont.body(17, weight: .bold))
                    .foregroundStyle(AppColors.gold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                isAnnual
                    ? AnyShapeStyle(AppColors.purple.opacity(0.3))
                    : AnyShapeStyle(AppColors.deepViolet.opacity(0.7)),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isAnnual ? AppColors.gold.opacity(0.5) : AppColors.purple.opacity(0.4),
                        lineWidth: isAnnual ? 1.5 : 1
                    )
            )
        }
    }

    private func subscriptionDescription(_ subscription: Product.SubscriptionInfo) -> String {
        switch subscription.subscriptionPeriod.unit {
        case .month: return "Billed monthly · Cancel anytime"
        case .year:  return "Billed annually · Best savings"
        default:     return "Renews automatically"
        }
    }
}
