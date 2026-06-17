//
//  LoveCoachView.swift
//  Twin Flame Union
//
//  AI Love Coach chat screen — powered by Claude.
//

import SwiftUI

struct LoveCoachView: View {
    @State private var viewModel = LoveCoachViewModel()
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            CosmicBackground()
                .accessibilityHidden(true)

            VStack(spacing: 0) {

                // MARK: Messages
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 14) {

                            // Intro card if no messages
                            if viewModel.messages.isEmpty {
                                IntroCard()
                                    .padding(.top, 20)
                            }

                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }

                            // Typing indicator
                            if viewModel.isStreaming && viewModel.messages.last?.content.isEmpty == true {
                                TypingIndicator()
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
                            } else {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.messages.last?.content) {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }

                // MARK: Input Bar
                InputBar(
                    text: $viewModel.inputText,
                    isFocused: $inputFocused,
                    isStreaming: viewModel.isStreaming
                ) {
                    Task { await viewModel.sendMessage() }
                }
            }
        }
        .navigationTitle("AI Love Coach")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .preferredColorScheme(.dark)
        .alert("Connection Lost", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Please try again.")
        }
        .onTapGesture {
            inputFocused = false
        }
    }
}

// MARK: - Intro Card

private struct IntroCard: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.purple.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .blur(radius: 12)
                    .accessibilityHidden(true)
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(AppGradients.warm)
                    .accessibilityHidden(true)
            }

            VStack(spacing: 8) {
                Text("I'm Seraphina")
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

private struct MessageBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isUser { Spacer(minLength: 50) }

            if !isUser {
                // Seraphina avatar
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
                        in: BubbleShape(isUser: isUser)
                    )
                    .overlay(
                        BubbleShape(isUser: isUser)
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

// MARK: - Bubble Shape

private struct BubbleShape: Shape, InsettableShape {
    let isUser: Bool
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18
        let tail: CGFloat = 6
        var path = Path()

        if isUser {
            path.addRoundedRect(in: rect.insetBy(dx: insetAmount, dy: insetAmount),
                                cornerSize: CGSize(width: r, height: r))
        } else {
            path.addRoundedRect(in: rect.insetBy(dx: insetAmount, dy: insetAmount),
                                cornerSize: CGSize(width: r, height: r))
        }
        _ = tail
        return path
    }

    func inset(by amount: CGFloat) -> BubbleShape {
        BubbleShape(isUser: isUser, insetAmount: amount)
    }
}

// MARK: - Typing Indicator

private struct TypingIndicator: View {
    @State private var phase = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ZStack {
                Circle()
                    .fill(AppColors.purple.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .accessibilityHidden(true)
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.gold)
                    .accessibilityHidden(true)
            }

            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(AppColors.lavender)
                        .frame(width: 7, height: 7)
                        .scaleEffect(phase == i ? 1.3 : 0.8)
                        .animation(
                            .calm(reduceMotion, .easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15)),
                            value: phase
                        )
                }
            }
            .accessibilityLabel("Seraphina is typing")
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

private struct InputBar: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let isStreaming: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Ask Seraphina anything...", text: $text, axis: .vertical)
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
                        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isStreaming
                            ? AppColors.lavender.opacity(0.4)
                            : AppColors.gold
                    )
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isStreaming)
            .accessibilityLabel(isStreaming ? "Sending" : "Send message")
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
