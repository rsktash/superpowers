package fixture

func CardLine(card *BeadCard) string {
	return FormatBeadLine(card.Status())
}
