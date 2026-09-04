BADGE_LIMIT = 12


def renderBadge(label):
    return "[{}]".format(label)


class BadgeCard:
    def summarize(self, label):
        return renderBadge(label)

    def renderBadge(self):
        return "card"


def orphanAnchor():
    return BADGE_LIMIT
