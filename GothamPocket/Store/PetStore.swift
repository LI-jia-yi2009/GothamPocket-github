import SwiftUI

@MainActor
final class PetStore: ObservableObject {
    @Published var companion: Companion {
        didSet { defaults.set(companion.rawValue, forKey: Keys.companion) }
    }

    @Published var mood: Double {
        didSet { defaults.set(mood, forKey: Keys.mood) }
    }

    @Published private(set) var message: String
    @Published private(set) var messageToken = UUID()
    @Published private(set) var effect: PetEffect?
    @Published private(set) var effectToken = UUID()

    @Published var rainEnabled: Bool {
        didSet { defaults.set(rainEnabled, forKey: Keys.rain) }
    }

    @Published var effectsEnabled: Bool {
        didSet { defaults.set(effectsEnabled, forKey: Keys.effects) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Keys.haptics) }
    }

    @Published var showSettings = false

    private let defaults: UserDefaults
    private var effectTask: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let saved = Companion(rawValue: defaults.string(forKey: Keys.companion) ?? "")
        companion = saved ?? .batman
        mood = defaults.object(forKey: Keys.mood) as? Double ?? 58
        message = (saved ?? .batman).greeting
        rainEnabled = defaults.object(forKey: Keys.rain) as? Bool ?? true
        effectsEnabled = defaults.object(forKey: Keys.effects) as? Bool ?? true
        hapticsEnabled = defaults.object(forKey: Keys.haptics) as? Bool ?? true
    }

    var moodLabel: String {
        switch mood {
        case ..<25: return "有点低落"
        case ..<48: return "安静"
        case ..<70: return "还不错"
        case ..<88: return "心情很好"
        default: return "开心到飞起"
        }
    }

    func tapPet() {
        mood = min(100, mood + 2)
        say(companion.tapLines.randomElement() ?? "……")
        trigger(.sparkle)
        Haptics.impact(.light, enabled: hapticsEnabled)
    }

    func feed() {
        guard mood < 96 else {
            say(companion.fullLines.randomElement() ?? "吃不下了。")
            trigger(.laugh)
            Haptics.impact(.soft, enabled: hapticsEnabled)
            return
        }

        mood = min(100, mood + 15)
        say(companion.feedLines.randomElement() ?? "谢谢。")
        trigger(.popcorn)
        Haptics.impact(.medium, enabled: hapticsEnabled)
    }

    func play() {
        mood = min(100, mood + 9)
        say(companion.playLines.randomElement() ?? "再来一次。")
        trigger(.hearts)
        Haptics.impact(.rigid, enabled: hapticsEnabled)
    }

    func tickle() {
        mood = min(100, mood + 5)
        say(companion.specialLines.randomElement() ?? "别闹。")
        trigger(.laugh)
        Haptics.notification(.success, enabled: hapticsEnabled)
    }

    func switchCompanion() {
        withAnimation(.easeInOut(duration: 0.4)) {
            companion = companion.next
        }
        message = companion.arrivalLine
        messageToken = UUID()
        trigger(.swap)
        Haptics.impact(.medium, enabled: hapticsEnabled)
    }

    func resetMood() {
        mood = 58
        message = "屋顶的灯，重新亮起来了。"
        messageToken = UUID()
        trigger(.sparkle)
        Haptics.notification(.success, enabled: hapticsEnabled)
    }

    private func say(_ line: String) {
        withAnimation(.easeOut(duration: 0.16)) {
            message = line
            messageToken = UUID()
        }
    }

    private func trigger(_ newEffect: PetEffect) {
        guard effectsEnabled else { return }

        let token = UUID()
        effectToken = token
        withAnimation(.spring(response: 0.34, dampingFraction: 0.7)) {
            effect = newEffect
        }

        effectTask?.cancel()
        effectTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 1_450_000_000)
            guard let self, !Task.isCancelled, self.effectToken == token else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                self.effect = nil
            }
        }
    }

    private enum Keys {
        static let companion = "gotham.companion"
        static let mood = "gotham.mood"
        static let rain = "gotham.rain"
        static let effects = "gotham.effects"
        static let haptics = "gotham.haptics"
    }
}

enum PetEffect: String, Identifiable {
    case popcorn
    case hearts
    case laugh
    case swap
    case sparkle

    var id: String { rawValue }

    var headline: String {
        switch self {
        case .popcorn: return "NOM!"
        case .hearts: return "AWW"
        case .laugh: return "HA!"
        case .swap: return "SWAP!"
        case .sparkle: return "ZAP!"
        }
    }

    var symbols: [String] {
        switch self {
        case .popcorn: return ["popcorn.fill", "star.fill", "sparkles"]
        case .hearts: return ["heart.fill", "sparkle", "heart.fill"]
        case .laugh: return ["face.smiling.inverse", "star.fill", "sparkles"]
        case .swap: return ["theatermasks.fill", "sparkles", "star.fill"]
        case .sparkle: return ["sparkles", "star.fill", "sparkle"]
        }
    }
}
