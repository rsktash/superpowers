def badgeSummary(label):
    # renderBadge mentioned in a comment
    ignored = "renderBadge in a string"
    return renderBadge(label)


def themeLimit():
    return BADGE_LIMIT


def localShadow():
    renderBadge = lambda label: label
    return renderBadge("shadow")


def importedAlias():
    from badge import renderBadge

    return renderBadge("imported")


def cardRender(card):
    return card.renderBadge()
