import SwiftUI

enum Companion: String, CaseIterable, Identifiable, Codable {
    case batman
    case joker

    var id: String { rawValue }

    var name: String {
        switch self {
        case .batman: return "蝙蝠侠"
        case .joker: return "小丑"
        }
    }

    var bubbleLabel: String {
        switch self {
        case .batman: return "BATMAN SAYS"
        case .joker: return "JOKER SAYS"
        }
    }

    var tagline: String {
        switch self {
        case .batman: return "哥谭屋顶的守夜人"
        case .joker: return "哥谭屋顶的麻烦制造者"
        }
    }

    var accent: Color {
        switch self {
        case .batman: return GothamTheme.batYellow
        case .joker: return GothamTheme.jokerGreen
        }
    }

    var secondaryAccent: Color {
        switch self {
        case .batman: return Color(hex: 0x5E8FB8)
        case .joker: return GothamTheme.jokerRed
        }
    }

    var skyTop: Color {
        switch self {
        case .batman: return Color(hex: 0x07111E)
        case .joker: return Color(hex: 0x170A22)
        }
    }

    var skyMiddle: Color {
        switch self {
        case .batman: return Color(hex: 0x10273A)
        case .joker: return Color(hex: 0x2A1240)
        }
    }

    var skyBottom: Color {
        switch self {
        case .batman: return Color(hex: 0x05070D)
        case .joker: return Color(hex: 0x08060D)
        }
    }

    var next: Companion {
        self == .batman ? .joker : .batman
    }

    var arrivalLine: String {
        switch self {
        case .batman: return "我来了。屋顶交给我。"
        case .joker: return "换班时间到——想我了吗？"
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch (self, hour) {
        case (.batman, 5..<12):
            return "天亮了。哥谭暂时安全。"
        case (.batman, 12..<18):
            return "白天的哥谭，反而更吵闹。"
        case (.batman, _):
            return "今晚的哥谭，还算安静。"
        case (.joker, 5..<12):
            return "早啊。我还没睡，你呢？"
        case (.joker, 12..<18):
            return "下午好。要来点恶作剧吗？"
        case (.joker, _):
            return "嘿嘿……夜生活才刚开始。"
        }
    }

    var idleLines: [String] {
        switch self {
        case .batman:
            return [
                "这座城市，今晚还算安静。",
                "别站太靠边，风很大。",
                "阿尔弗雷德说，我该多笑笑。",
                "你听见蝙蝠灯亮了吗？",
                "罗宾又偷吃了我的三明治。"
            ]
        case .joker:
            return [
                "嘿嘿……你终于来了。",
                "为什么这么严肃？",
                "蝙蝠仔又不理我了。",
                "今晚的哥谭，真热闹。",
                "我刚刚想到一个特别好笑的点子。"
            ]
        }
    }

    var feedLines: [String] {
        switch self {
        case .batman:
            return [
                "……爆米花？就这一次。",
                "高热量的东西。下不为例。",
                "阿尔弗雷德不会同意这个夜宵。"
            ]
        case .joker:
            return [
                "爆米花！我就知道你喜欢我。",
                "再来点焦糖，别害羞。",
                "蝙蝠仔不吃，那都是我的。"
            ]
        }
    }

    var playLines: [String] {
        switch self {
        case .batman:
            return [
                "认真点。……好吧，再来一次。",
                "我可不常这样。",
                "别告诉小丑。"
            ]
        case .joker:
            return [
                "哈！再来一次！",
                "你比我还有趣。",
                "小心，我笑点很低的。"
            ]
        }
    }

    var tapLines: [String] {
        switch self {
        case .batman:
            return [
                "嗯？",
                "我在听。",
                "你挡住我的视线了。",
                "……谢谢。"
            ]
        case .joker:
            return [
                "戳我？胆子不小。",
                "嘿嘿嘿……痒。",
                "想听个笑话吗？",
                "再戳一下，我就咬人。"
            ]
        }
    }

    var specialLines: [String] {
        switch self {
        case .batman:
            return [
                "好吧。五分钟。就五分钟。",
                "哥谭可以等我一会儿。"
            ]
        case .joker:
            return [
                "我给你留了张牌。……别翻。",
                "严肃脸不适合你。"
            ]
        }
    }

    var fullLines: [String] {
        switch self {
        case .batman:
            return ["吃不下了。真的。", "再吃，披风就扣不上了。"]
        case .joker:
            return ["停停停——我笑不出来了。", "留着点肚子，等蝙蝠仔请客。"]
        }
    }
}
