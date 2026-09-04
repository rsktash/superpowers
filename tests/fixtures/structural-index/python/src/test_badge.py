def test_render():
    assert renderBadge("unit")


def test_limit():
    assert BADGE_LIMIT == 12


def test_card():
    card = BadgeCard()
    return card.summarize("unit")
