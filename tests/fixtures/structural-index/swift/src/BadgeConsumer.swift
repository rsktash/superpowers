import func BadgeKit.renderBadge

func badgeSummary(_ label: String) -> String {
    // renderBadge mentioned in a comment
    let ignored = "renderBadge in a string"
    return renderBadge(label)
}

func themeAccent() -> String {
    return BadgeTheme.accent
}

func cardSummary(_ card: BadgeCard) -> String {
    return card.summarize("unit")
}
