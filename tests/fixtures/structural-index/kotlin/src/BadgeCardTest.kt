package fixture

fun badgeCardTest() {
    val renderer = object : BadgeRenderer {
        override fun render(label: String): String = label
    }
    val card = BadgeCard(renderer)
    card.summarize("test")
    renderBadge("unit")
}
