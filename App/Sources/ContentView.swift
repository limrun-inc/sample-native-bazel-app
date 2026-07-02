import Combine
import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    private enum GamePhase {
        case start
        case playing
        case gameOver
    }

    private let gameIntervals = [2.0, 3.0, 5.0]
    private let circleColors: [Color] = [
        Color(red: 1.00, green: 0.28, blue: 0.44),
        Color(red: 0.20, green: 0.54, blue: 1.00),
        Color(red: 0.19, green: 0.80, blue: 0.56),
        Color(red: 1.00, green: 0.69, blue: 0.20),
        Color(red: 0.58, green: 0.35, blue: 1.00),
    ]

    private let minimumCircleDiameter: CGFloat = 44
    private let startingCircleDiameter: CGFloat = 116
    private let circleShrinkFactor: CGFloat = 0.91
    private let ticker = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

    @State private var selectedInterval = 3.0
    @State private var phase: GamePhase = .start
    @State private var score = 0
    @State private var remainingTime = 3.0
    @State private var roundEndsAt = Date()
    @State private var circleDiameter: CGFloat = 116
    @State private var circlePosition = CGPoint(x: 180, y: 360)
    @State private var circleColorIndex = 0
    @State private var playAreaSize = CGSize(width: 390, height: 844)

    private var circleColor: Color {
        circleColors[circleColorIndex]
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                backgroundGradient

                switch phase {
                case .start:
                    startView(in: proxy.size)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                case .playing:
                    gameplayView(in: proxy.size)
                        .transition(.opacity.combined(with: .scale(scale: 1.04)))
                case .gameOver:
                    gameOverView
                        .transition(.opacity.combined(with: .scale(scale: 0.94)))
                }
            }
            .onAppear {
                playAreaSize = proxy.size
                circlePosition = randomCirclePosition(in: proxy.size, diameter: circleDiameter)
            }
            .onChange(of: proxy.size) { newSize in
                playAreaSize = newSize
                circlePosition = clampedCirclePosition(circlePosition, in: newSize, diameter: circleDiameter)
            }
            .onReceive(ticker) { now in
                updateCountdown(now: now)
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.08, blue: 0.18),
                Color(red: 0.11, green: 0.16, blue: 0.33),
                Color(red: 0.08, green: 0.10, blue: 0.23),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 260, height: 260)
                    .blur(radius: 4)
                    .offset(x: -170, y: -270)
                Circle()
                    .fill(Color(red: 0.20, green: 0.54, blue: 1.00).opacity(0.16))
                    .frame(width: 320, height: 320)
                    .blur(radius: 10)
                    .offset(x: 180, y: 260)
            }
        }
        .ignoresSafeArea()
    }

    private func startView(in size: CGSize) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)

            VStack(spacing: 14) {
                Image(systemName: "circle.grid.cross")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.hierarchical)
                    .padding(18)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.13))
                            .overlay(Circle().stroke(Color.white.opacity(0.22), lineWidth: 1))
                    )

                Text("Speedy Circles")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Tap each circle before the timer expires. Every hit makes the target smaller, faster to track, and worth one more point.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Round timer")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .textCase(.uppercase)

                Picker("Round timer", selection: $selectedInterval) {
                    ForEach(gameIntervals, id: \.self) { interval in
                        Text("\(interval, specifier: "%.1f")s").tag(interval)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )

            Button {
                startGame(in: size)
            } label: {
                Label("Start", systemImage: "play.fill")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(PrimaryGameButtonStyle())
            .accessibilityHint("Starts a Speedy Circles game with the selected timer.")

            Spacer(minLength: 28)
        }
        .padding(.horizontal, 24)
    }

    private func gameplayView(in size: CGSize) -> some View {
        ZStack {
            circleTarget
                .position(circlePosition)
                .animation(.spring(response: 0.36, dampingFraction: 0.78), value: circlePosition)
                .animation(.spring(response: 0.32, dampingFraction: 0.74), value: circleDiameter)
                .animation(.easeInOut(duration: 0.22), value: circleColorIndex)

            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    StatCard(title: "Score", value: "\(score)", symbolName: "star.fill")
                    StatCard(title: "Time", value: formattedTime, symbolName: "timer")
                }

                ProgressView(value: timeProgress)
                    .tint(progressTint)
                    .scaleEffect(x: 1, y: 1.8, anchor: .center)
                    .clipShape(Capsule())
                    .accessibilityLabel("Remaining time")
                    .accessibilityValue(formattedTime)

                Spacer()

                Text("Tap the circle")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .onAppear {
            playAreaSize = size
        }
    }

    private var circleTarget: some View {
        Button {
            hitCircle()
        } label: {
            Circle()
                .fill(circleColor)
                .frame(width: circleDiameter, height: circleDiameter)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.58), lineWidth: max(2, circleDiameter * 0.035))
                )
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.40), Color.white.opacity(0)],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                        .padding(circleDiameter * 0.12)
                        .allowsHitTesting(false)
                )
                .shadow(color: circleColor.opacity(0.45), radius: 26, x: 0, y: 16)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Circle target")
        .accessibilityHint("Tap before time runs out.")
    }

    private var gameOverView: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 32)

            VStack(spacing: 18) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(Circle().fill(Color.white.opacity(0.14)))

                VStack(spacing: 8) {
                    Text("Time's Up")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Final Score")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.68))
                        .textCase(.uppercase)

                    Text("\(score)")
                        .font(.system(size: 88, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                }

                Text(score == 0 ? "Warm up and try again." : "Nice reflexes. Can you beat it?")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 34)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )

            Button {
                resetToStart()
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(PrimaryGameButtonStyle())
            .accessibilityHint("Returns to the start screen.")

            Spacer(minLength: 28)
        }
        .padding(.horizontal, 24)
    }

    private var formattedTime: String {
        String(format: "%.1fs", max(0, remainingTime))
    }

    private var timeProgress: Double {
        guard selectedInterval > 0 else { return 0 }
        return max(0, min(1, remainingTime / selectedInterval))
    }

    private var progressTint: Color {
        switch timeProgress {
        case 0.34...:
            return Color(red: 0.24, green: 0.84, blue: 0.58)
        case 0.16..<0.34:
            return Color(red: 1.00, green: 0.70, blue: 0.20)
        default:
            return Color(red: 1.00, green: 0.28, blue: 0.44)
        }
    }

    private func startGame(in size: CGSize) {
        playAreaSize = size
        score = 0
        circleDiameter = startingCircleDiameter
        remainingTime = selectedInterval
        roundEndsAt = Date().addingTimeInterval(selectedInterval)
        circleColorIndex = nextCircleColorIndex(excluding: circleColorIndex)
        circlePosition = randomCirclePosition(in: size, diameter: circleDiameter)

        withAnimation(.spring(response: 0.48, dampingFraction: 0.86)) {
            phase = .playing
        }
    }

    private func hitCircle() {
        guard phase == .playing else { return }

        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif

        let nextDiameter = max(minimumCircleDiameter, circleDiameter * circleShrinkFactor)
        withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
            score += 1
            circleDiameter = nextDiameter
            circleColorIndex = nextCircleColorIndex(excluding: circleColorIndex)
            circlePosition = randomCirclePosition(in: playAreaSize, diameter: nextDiameter)
            remainingTime = selectedInterval
            roundEndsAt = Date().addingTimeInterval(selectedInterval)
        }
    }

    private func updateCountdown(now: Date) {
        guard phase == .playing else { return }

        let updatedRemainingTime = roundEndsAt.timeIntervalSince(now)
        if updatedRemainingTime <= 0 {
            remainingTime = 0
            withAnimation(.spring(response: 0.48, dampingFraction: 0.88)) {
                phase = .gameOver
            }
        } else {
            remainingTime = updatedRemainingTime
        }
    }

    private func resetToStart() {
        withAnimation(.spring(response: 0.46, dampingFraction: 0.86)) {
            phase = .start
            score = 0
            remainingTime = selectedInterval
            circleDiameter = startingCircleDiameter
        }
    }

    private func randomCirclePosition(in size: CGSize, diameter: CGFloat) -> CGPoint {
        let radius = diameter / 2
        let horizontalPadding = max(24 + radius, radius)
        let topPadding = max(160 + radius, radius)
        let bottomPadding = max(84 + radius, radius)
        let minX = horizontalPadding
        let maxX = max(minX, size.width - horizontalPadding)
        let minY = topPadding
        let maxY = max(minY, size.height - bottomPadding)

        return CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }

    private func clampedCirclePosition(_ point: CGPoint, in size: CGSize, diameter: CGFloat) -> CGPoint {
        let radius = diameter / 2
        let minX = max(24 + radius, radius)
        let maxX = max(minX, size.width - minX)
        let minY = max(160 + radius, radius)
        let maxY = max(minY, size.height - max(84 + radius, radius))

        return CGPoint(
            x: min(max(point.x, minX), maxX),
            y: min(max(point.y, minY), maxY)
        )
    }

    private func nextCircleColorIndex(excluding currentIndex: Int) -> Int {
        let candidates = circleColors.indices.filter { $0 != currentIndex }
        return candidates.randomElement() ?? currentIndex
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let symbolName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbolName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.white.opacity(0.14)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.64))
                    .textCase(.uppercase)

                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }
}

private struct PrimaryGameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.18, green: 0.50, blue: 1.00),
                        Color(red: 0.56, green: 0.32, blue: 1.00),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .shadow(color: Color(red: 0.28, green: 0.38, blue: 1.00).opacity(configuration.isPressed ? 0.18 : 0.36), radius: configuration.isPressed ? 10 : 20, x: 0, y: configuration.isPressed ? 5 : 12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
