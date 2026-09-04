package fixture

import "testing"

func TestValidateStatus(t *testing.T) {
	if !ValidateStatus("active") {
		t.Fatal("active status rejected")
	}
}
