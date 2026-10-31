import SwiftUI

struct PetPlayground: View {
    @ObservedObject var store: PetStore

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    var body: some View {
        GeometryReader { geo in
            let horizontalScale = geo.size.width / 292.0
            let verticalScale = max(0.1, (geo.size.height - 128.0) / 310.0)
            let scale = max(0.58, min(1.08, min(horizontalScale, verticalScale)))

            ZStack(alignment: .bottom) {
                characterLayer(scale: scale)

                speechBubble(width: min(geo.size.width * 0.86, 330))
                    .padding(.bottom, 315 * scale + 8)

                if store.effectsEnabled, let effect = store.effect {
                    EffectBurst(effect: effect, companion: store.companion)
                        .id(store.effectToken)
                        .offset(y: 28)
                        .transition(.opacity)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func speechBubble(width: CGFloat) -> some View {
        SpeechBubble(
            text: store.message,
            label: store.companion.bubbleLabel,
            accent: store.companion.accent
        )
        .id(store.messageToken)
        .frame(maxWidth: width)
        .transition(
            .asymmetric(
                insertion: .scale(scale: 0.9, anchor: .bottomLeading)
                    .combined(with: .opacity),
                removal: .opacity
            )
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: store.messageToken)
        .allowsHitTesting(false)
    }

    private func characterLayer(scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            ZStack(alignment: .bottom) {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                store.companion.accent.opacity(0.28),
                                store.companion.accent.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 110 * scale
                        )
                    )
                    .frame(width: 270 * scale, height: 54 * scale)
                    .blur(radius: 9)
                    .offset(y: 2)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0x25324A), Color(hex: 0x080C14)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(store.companion.accent.opacity(0.30), lineWidth: 1)
                    )
                    .frame(width: 264 * scale, height: 14 * scale)
                    .shadow(color: store.companion.accent.opacity(0.18), radius: 12)
                    .offset(y: 5 * scale)

                TimelineView(.animation(
                    minimumInterval: 1.0 / 30.0,
                    paused: reduceMotion
                )) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let bob = reduceMotion ? 0 : CGFloat(sin(time * 2.0) * 3.5)
                    let sway = reduceMotion ? 0 : sin(time * 0.9) * 0.7

                    CharacterArt(
                        companion: store.companion,
                        mood: store.mood,
                        time: time
                    )
                    .scaleEffect(scale)
                    .frame(width: 240 * scale, height: 300 * scale)
                    .offset(y: bob)
                    .rotationEffect(.degrees(sway))
                }
                .id(store.companion)
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.75, anchor: .bottom)
                            .combined(with: .opacity),
                        removal: .scale(scale: 1.15, anchor: .bottom)
                            .combined(with: .opacity)
                    )
                )
                .frame(width: 250 * scale, height: 306 * scale)
                .contentShape(Rectangle())
                .offset(x: dragOffset.width, y: dragOffset.height)
                .rotationEffect(.degrees(Double(dragOffset.width / 30.0)))
                .scaleEffect(x: isDragging ? 1.03 : 1.0, y: isDragging ? 0.97 : 1.0)
                .gesture(dragGesture)
                .onTapGesture {
                    store.tapPet()
                }
                .onLongPressGesture(minimumDuration: 0.62) {
                    store.tickle()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(store.companion.name)，\(store.moodLabel)")
                .accessibilityHint("轻点摸摸他，长按逗逗他，也可以拖动")
                .accessibilityAddTraits(.isButton)
                .accessibilityAction {
                    store.tapPet()
                }
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.75),
                    value: store.companion
                )
            }
            .padding(.bottom, 4)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                }
                dragOffset = CGSize(
                    width: bounded(value.translation.width * 0.55, -68, 68),
                    height: bounded(value.translation.height * 0.45, -52, 52)
                )
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.52, dampingFraction: 0.55)) {
                    dragOffset = .zero
                    isDragging = false
                }
            }
    }

    private func bounded(_ value: CGFloat, _ lower: CGFloat, _ upper: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, lower), upper)
    }
}
