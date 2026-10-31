import UIKit

enum Haptics {
    @MainActor
    static func impact(
        _ style: UIImpactFeedbackGenerator.FeedbackStyle,
        enabled: Bool
    ) {
        guard enabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor
    static func notification(
        _ type: UINotificationFeedbackGenerator.FeedbackType,
        enabled: Bool
    ) {
        guard enabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
