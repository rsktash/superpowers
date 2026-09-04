package fixture

type BeadStatus string

type BeadCard struct {
	State BeadStatus
}

func (c *BeadCard) Status() BeadStatus {
	return c.State
}
