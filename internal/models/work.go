package models

// Work represents a work item (feature, fix, etc.)
type Work struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	Status    string `json:"status"`
	CreatedAt string `json:"createdAt"`
	UpdatedAt string `json:"updatedAt"`
	Proposal  string `json:"proposal"`
}
