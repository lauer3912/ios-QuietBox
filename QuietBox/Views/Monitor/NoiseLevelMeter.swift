import SwiftUI

struct NoiseLevelMeter: View {
    let db: Double
    let threshold: Double
    let isMonitoring: Bool

    @State private var animatedDb: Double = 0
    @State private var pulseAnimation = false

    private let maxDb: Double = 120

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(AdaptiveColors().card, lineWidth: 20)
                .frame(width: 250, height: 250)

            // Level arc
            Circle()
                .trim(from: 0, to: CGFloat(animatedDb / maxDb))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))

            // Threshold indicator
            Circle()
                .trim(from: CGFloat(threshold / maxDb) - 0.02, to: CGFloat(threshold / maxDb) + 0.02)
                .stroke(ThemeManager.Colors.warning, lineWidth: 4)
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))

            // Pulsing ring when loud
            if db > threshold && isMonitoring {
                Circle()
                    .stroke(ThemeManager.Colors.danger.opacity(0.5), lineWidth: 4)
                    .frame(width: 260, height: 260)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .opacity(pulseAnimation ? 0 : 0.8)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: false), value: pulseAnimation)
            }

            // Level indicators
            VStack(spacing: 4) {
                ForEach([0, 30, 60, 90, 120], id: \.self) { level in
                    Text("\(level)")
                        .font(.system(size: 10))
                        .foregroundColor(AdaptiveColors().textSecondary)
                        .offset(x: level == 0 ? -140 : level == 120 ? 130 : 0)
                }
            }
            .frame(width: 250, height: 250)
        }
        .onChange(of: db) { _, newValue in
            withAnimation(.easeOut(duration: 0.1)) {
                animatedDb = newValue
            }
        }
        .onChange(of: pulseAnimation) { _, newValue in
            if db > threshold && isMonitoring && !newValue {
                pulseAnimation = true
            } else if db <= threshold {
                pulseAnimation = false
            }
        }
        .onAppear {
            animatedDb = db
            if db > threshold && isMonitoring {
                pulseAnimation = true
            }
        }
    }

    private var gradientColors: [Color] {
        let thresholdRatio = threshold / maxDb
        let dbRatio = db / maxDb

        if dbRatio < thresholdRatio * 0.7 {
            return [ThemeManager.Colors.levelQuiet, ThemeManager.Colors.levelModerate]
        } else if dbRatio < thresholdRatio {
            return [ThemeManager.Colors.levelModerate, ThemeManager.Colors.levelLoud]
        } else {
            return [ThemeManager.Colors.levelLoud, ThemeManager.Colors.levelVeryLoud]
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        NoiseLevelMeter(db: 45, threshold: 60, isMonitoring: true)
        NoiseLevelMeter(db: 75, threshold: 60, isMonitoring: true)
        NoiseLevelMeter(db: 95, threshold: 60, isMonitoring: true)
    }
    .padding()
}