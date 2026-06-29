import SwiftUI

struct StatusLightView: View {
    let status: AgentStatus
    var size: CGFloat = 56

    @State private var blink = true

    var body: some View {
        Group {
            if status == .thinking {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    lightContent(breathPhase: breathPhase(at: timeline.date))
                }
            } else {
                lightContent(breathPhase: nil)
            }
        }
        .animation(nil, value: status)
        .onAppear { restartBlinkAnimation() }
        .onChange(of: status) { _, _ in restartBlinkAnimation() }
    }

    private func breathPhase(at date: Date) -> Double {
        let cycle = 1.8
        let t = date.timeIntervalSinceReferenceDate
        return (sin(t * 2 * .pi / cycle) + 1) / 2
    }

    private func lightContent(breathPhase: Double?) -> some View {
        let breathing = breathPhase ?? 0
        let isBreathing = breathPhase != nil

        let glowOpacity = isBreathing
            ? 0.2 + breathing * 0.75
            : glowOpacityForBlink
        let coreOpacity = isBreathing
            ? 0.45 + breathing * 0.55
            : coreOpacityForBlink
        let coreScale = isBreathing
            ? 0.92 + breathing * 0.14
            : 1.0

        return ZStack {
            Circle()
                .fill(color.opacity(glowOpacity))
                .frame(width: size * 1.7, height: size * 1.7)
                .blur(radius: size * 0.22)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(coreOpacity),
                            color.opacity(coreOpacity * 0.65),
                            color.opacity(coreOpacity * 0.2)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(coreScale)
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                        .blendMode(.overlay)
                }
                .shadow(color: color.opacity(isBreathing ? 0.25 + breathing * 0.35 : 0.45), radius: size * 0.12)
        }
        .transaction { transaction in
            if !isBreathing {
                transaction.animation = blinkAnimation
            }
        }
    }

    private var color: Color {
        switch status {
        case .idle:
            return Color(red: 0.18, green: 0.88, blue: 0.42)
        case .thinking, .executing:
            return Color(red: 0.22, green: 0.58, blue: 1.0)
        case .processing:
            return Color(red: 0.68, green: 0.32, blue: 1.0)
        case .error:
            return Color(red: 1.0, green: 0.28, blue: 0.28)
        case .waiting:
            return Color(red: 1.0, green: 0.82, blue: 0.18)
        }
    }

    private var glowOpacityForBlink: Double {
        switch status {
        case .idle: return 0.55
        default: return blink ? 0.9 : 0.15
        }
    }

    private var coreOpacityForBlink: Double {
        switch status {
        case .idle: return 1.0
        default: return blink ? 1.0 : 0.35
        }
    }

    private var blinkAnimation: Animation? {
        switch status {
        case .executing: return .easeInOut(duration: 0.35).repeatForever(autoreverses: true)
        case .processing: return .easeInOut(duration: 0.55).repeatForever(autoreverses: true)
        case .error: return .easeInOut(duration: 0.45).repeatForever(autoreverses: true)
        case .waiting: return .easeInOut(duration: 0.7).repeatForever(autoreverses: true)
        default: return nil
        }
    }

    private func restartBlinkAnimation() {
        guard status != .thinking && status != .idle else {
            blink = true
            return
        }

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            blink = true
        }

        let duration: TimeInterval = switch status {
        case .executing: 0.35
        case .processing: 0.55
        case .error: 0.45
        case .waiting: 0.7
        default: 0.5
        }

        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            blink = false
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        ForEach(AgentStatus.allCases, id: \.self) { status in
            HStack {
                StatusLightView(status: status)
                Text(status.label)
            }
        }
    }
    .padding()
    .background(Color.black.opacity(0.85))
}
