package fixture

import fixture.renderBadge

fun badgeSummary(label: String): String {
    // renderBadge mentioned in a comment
    val ignored = "renderBadge in a string"
    return renderBadge(label)
}

fun themeAccent(): String = BadgeTheme.accent

fun cardSummary(renderer: BadgeRenderer, label: String): String {
    return BadgeCard(renderer).summarize(label)
}
