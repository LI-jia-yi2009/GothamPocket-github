import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: PetStore

    var body: some View {
        ZStack {
            GothamSky(
                companion: store.companion,
                rainEnabled: store.rainEnabled
            )

            VStack(spacing: 8) {
                header

                PetPlayground(store: store)
                    .frame(maxHeight: .infinity)
                    .layoutPriority(1)

                controlPanel
            }
            .padding(.horizontal, 18)
            .padding(.top, 4)
            .padding(.bottom, 6)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $store.showSettings) {
            SettingsSheet(store: store)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.black.opacity(0.34))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(store.companion.accent.opacity(0.4), lineWidth: 1)
                    }

                if store.companion == .batman {
                    BatEmblem()
                        .fill(store.companion.accent)
                        .padding(9)
                } else {
                    Text("HA")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(store.companion.accent)
                        .rotationEffect(.degrees(-8))
                }
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text("GOTHAM POCKET")
                    .font(.system(size: 7.5, weight: .black, design: .monospaced))
                    .tracking(2.2)
                    .foregroundStyle(store.companion.accent.opacity(0.9))

                Text("哥谭口袋")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(store.companion.tagline)
                    .font(.system(size: 8.5, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.38))
            }

            Spacer(minLength: 4)

            Button {
                store.switchCompanion()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 10, weight: .bold))
                    Text("换班 · \(store.companion.next.name)")
                        .font(.system(size: 9.5, weight: .bold, design: .rounded))
                }
                .foregroundStyle(store.companion.accent)
                .padding(.horizontal, 10)
                .frame(height: 34)
                .background(Capsule().fill(Color.white.opacity(0.06)))
                .overlay(
                    Capsule().stroke(store.companion.accent.opacity(0.26), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("换班，切换到\(store.companion.next.name)")

            Button {
                store.showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color.white.opacity(0.06)))
                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("设置")
        }
    }

    private var controlPanel: some View {
        VStack(spacing: 11) {
            HStack(spacing: 6) {
                Circle()
                    .fill(store.companion.accent)
                    .frame(width: 6, height: 6)

                Text(store.companion.name)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("· \(store.moodLabel)")
                    .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.42))

                Spacer()

                Text("\(Int(store.mood))")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(store.companion.accent.opacity(0.75))
            }

            MoodBar(progress: store.mood / 100, tint: store.companion.accent)
                .frame(height: 6)

            HStack(spacing: 9) {
                SimpleActionButton(
                    icon: "popcorn.fill",
                    title: "投喂",
                    subtitle: "爆米花",
                    tint: store.companion.accent
                ) {
                    store.feed()
                }

                SimpleActionButton(
                    icon: "hand.wave.fill",
                    title: "逗一逗",
                    subtitle: "陪他玩",
                    tint: store.companion.secondaryAccent
                ) {
                    store.play()
                }
            }

            Text("轻点摸摸 · 长按逗他 · 还能拖着走")
                .font(.system(size: 8.5, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.30))
        }
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.black.opacity(0.22))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(store.companion.accent.opacity(0.22), lineWidth: 1)
                }
        }
        .shadow(color: .black.opacity(0.45), radius: 20, x: 0, y: 12)
        .animation(.easeInOut(duration: 0.3), value: store.companion)
    }
}

private struct MoodBar: View {
    let progress: Double
    let tint: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.08))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.5), tint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(6, geo.size.width * CGFloat(min(max(progress, 0), 1)))
                    )
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: progress)
        .accessibilityLabel("心情")
        .accessibilityValue("\(Int(progress * 100))%")
    }
}

private struct SimpleActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Text(subtitle)
                        .font(.system(size: 8.5, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.38))
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.1))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(tint.opacity(0.22), lineWidth: 1)
            }
        }
        .buttonStyle(PressableButtonStyle())
        .foregroundStyle(tint)
        .accessibilityLabel("\(title)，\(subtitle)")
    }
}

private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.84 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
