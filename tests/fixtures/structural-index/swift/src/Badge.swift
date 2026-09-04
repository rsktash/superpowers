let BADGE_LIMIT = 12

func renderBadge(_ label: String) -> String {
    return "[\(label)]"
}

class BadgeCard {
    func summarize(_ label: String) -> String {
        return renderBadge(label)
    }

    func renderBadge() -> String {
        return "card"
    }
}

struct BadgeTheme {
    static let accent = "indigo"
}

func orphanAnchor() -> Int {
    return BADGE_LIMIT
}
