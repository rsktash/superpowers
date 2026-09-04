package board

import "example.com/fixture"

func Summary(status fixture.BeadStatus) string {
	return fixture.FormatBeadLine(string(status))
}
