import SwiftUI

struct ContentView: View {
    private enum GamePhase: Equatable {
        case start
        case playing
        case gameOver
    }

    private struct IntervalOption: Identifiable {
        let id: TimeInterval
        let label: String
    }

    private let intervalOptions = [
        IntervalOption(id: 2.0, label: "2.0s"),
        IntervalOption(id: 3.0, label: "3.0s"),
        IntervalOption(id: 5.0, label: "5.0s"),
    ]
    private let startingCircleDiameter: CGFloat = 110
    private let minimumCircleDiameter: CGFloat = 38
    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    @State private var phase: GamePhase = .start
    @State private var selectedInterval: TimeInterval = 3.0
    @State private var score = 0
    @State private var finalScore = 0
    @State private var remainingTime: TimeInterval = 3.0
    @State private var deadline = Date()
    @State private var circleDiameter: CGFloat = 110
    @State private var circleColor = Color(red: 0.96, green: 0.28, blue: 0.39)
    @State private var circlePosition = CGPoint(x: 160, y: 360)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background

                switch phase {
                case .start:
                    startScreen(in: geometry.size)
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                case .playing:
                    gameScreen(in: geometry.size)
                        .transition(.opacity)
                case .gameOver:
                    gameOverScreen
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(timer) { now in
                updateTimer(now: now)
            }
        }
        .ignoresSafeArea()
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.07, blue: 0.16),
                Color(red: 0.11, green: 0.16, blue: 0.34),
                Color(red: 0.17, green: 0.08, blue: 0.24),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func startScreen(in size: CGSize) -> some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 10) {
                Text("Speedy Circles")
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Pick a countdown, then tap each circle before the timer expires.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.76))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 26)
            }

            VStack(spacing: 14) {
                Text("Round timer")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))

                HStack(spacing: 12) {
                    ForEach(intervalOptions) { option in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                                selectedInterval = option.id
                                remainingTime = option.id
                            }
                        } label: {
                            Text(option.label)
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    Capsule()
                                        .fill(selectedInterval == option.id ? Color.white : Color.white.opacity(0.14))
                                )
                                .foregroundStyle(selectedInterval == option.id ? Color(red: 0.11, green: 0.16, blue: 0.34) : .white)
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(selectedInterval == option.id ? 0 : 0.22), lineWidth: 1)
                                )
                        }
                        .accessibilityIdentifier("interval-\(option.label)")
                    }
                }
            }
            .padding(22)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 24)

            Button {
                startGame(in: size)
            } label: {
                Text("Start")
                    .font(.title3.weight(.black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.36, green: 0.91, blue: 0.72), Color(red: 0.35, green: 0.66, blue: 1.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .foregroundStyle(Color(red: 0.03, green: 0.06, blue: 0.14))
                    .shadow(color: Color(red: 0.35, green: 0.66, blue: 1.0).opacity(0.35), radius: 18, y: 8)
            }
            .padding(.horizontal, 42)
            .accessibilityIdentifier("startButton")

            Spacer()
        }
    }

    private func gameScreen(in size: CGSize) -> some View {
        ZStack {
            VStack(spacing: 18) {
                HStack(spacing: 14) {
                    statCard(title: "Score", value: "\(score)")
                        .accessibilityIdentifier("scoreLabel")
                    statCard(title: "Time", value: formattedTime(remainingTime))
                        .accessibilityIdentifier("timeLabel")
                }
                .padding(.horizontal, 20)
                .padding(.top, 58)

                Text("Tap the circle before time runs out.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.72))

                Spacer()
            }

            Circle()
                .fill(circleColor)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.72), lineWidth: 4)
                )
                .shadow(color: circleColor.opacity(0.55), radius: 22, y: 10)
                .frame(width: circleDiameter, height: circleDiameter)
                .position(circlePosition)
                .contentShape(Circle())
                .onTapGesture {
                    hitCircle(in: size)
                }
                .accessibilityLabel("Circle")
                .accessibilityIdentifier("gameCircle")
                .accessibilityAddTraits(.isButton)
                .animation(.spring(response: 0.34, dampingFraction: 0.72), value: circlePosition)
                .animation(.spring(response: 0.34, dampingFraction: 0.72), value: circleDiameter)
                .animation(.easeInOut(duration: 0.22), value: circleColor)
        }
    }

    private var gameOverScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("Time's Up")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("Final Score")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))

                Text("\(finalScore)")
                    .font(.system(size: 86, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.36, green: 0.91, blue: 0.72), Color(red: 0.35, green: 0.66, blue: 1.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .accessibilityIdentifier("finalScoreLabel")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 38)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .padding(.horizontal, 28)

            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                    phase = .start
                    score = 0
                    remainingTime = selectedInterval
                    circleDiameter = startingCircleDiameter
                }
            } label: {
                Text("Retry")
                    .font(.title3.weight(.black))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white, in: Capsule())
                    .foregroundStyle(Color(red: 0.11, green: 0.16, blue: 0.34))
            }
            .padding(.horizontal, 42)
            .accessibilityIdentifier("retryButton")

            Spacer()
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(.white.opacity(0.58))
            Text(value)
                .font(.title2.monospacedDigit().weight(.black))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func startGame(in size: CGSize) {
        let now = Date()

        score = 0
        finalScore = 0
        circleDiameter = startingCircleDiameter
        circleColor = nextCircleColor()
        circlePosition = randomCirclePosition(for: startingCircleDiameter, in: size)
        remainingTime = selectedInterval
        deadline = now.addingTimeInterval(selectedInterval)

        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
            phase = .playing
        }
    }

    private func hitCircle(in size: CGSize) {
        guard phase == .playing else { return }

        let newDiameter = max(minimumCircleDiameter, circleDiameter * 0.88)
        score += 1
        circleDiameter = newDiameter
        circleColor = nextCircleColor()
        circlePosition = randomCirclePosition(for: newDiameter, in: size)
        remainingTime = selectedInterval
        deadline = Date().addingTimeInterval(selectedInterval)
    }

    private func updateTimer(now: Date) {
        guard phase == .playing else { return }

        let secondsLeft = deadline.timeIntervalSince(now)
        remainingTime = max(0, secondsLeft)

        if secondsLeft <= 0 {
            finalScore = score
            withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                phase = .gameOver
            }
        }
    }

    private func randomCirclePosition(for diameter: CGFloat, in size: CGSize) -> CGPoint {
        let rect = playableRect(in: size)
        let radius = diameter / 2
        let minX = rect.minX + radius
        let maxX = max(minX, rect.maxX - radius)
        let minY = rect.minY + radius
        let maxY = max(minY, rect.maxY - radius)

        return CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }

    private func playableRect(in size: CGSize) -> CGRect {
        let horizontalPadding: CGFloat = 28
        let topPadding = max(168, size.height * 0.24)
        let bottomPadding: CGFloat = 58
        let width = max(0, size.width - horizontalPadding * 2)
        let height = max(120, size.height - topPadding - bottomPadding)

        return CGRect(
            x: horizontalPadding,
            y: topPadding,
            width: width,
            height: height
        )
    }

    private func nextCircleColor() -> Color {
        Color(
            hue: Double.random(in: 0...1),
            saturation: Double.random(in: 0.68...0.94),
            brightness: Double.random(in: 0.78...1.0)
        )
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        String(format: "%.2f", max(0, time))
    }
}

#Preview {
    ContentView()
}
