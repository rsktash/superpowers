package fixture

const val BADGE_LIMIT = 12

fun renderBadge(label: String): String {
    return "[$label]"
}

interface BadgeRenderer {
    fun render(label: String): String
}

class BadgeCard(private val renderer: BadgeRenderer) {
    private val prefix: String = "badge"

    fun summarize(label: String): String {
        return renderBadge(label) + renderer.render(label)
    }

    fun renderBadge(): String {
        return "card"
    }
}

object BadgeTheme {
    val accent: String = "indigo"
}

fun orphanAnchor(): Int = BADGE_LIMIT
