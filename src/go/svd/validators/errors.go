package validators

import "strings"

// ValidatorException represents validation exceptions.
type ValidatorException struct {
	Errors []ValidationError
}

// NewValidatorException creates a new ValidatorException.
func NewValidatorException(errors []ValidationError) *ValidatorException {
	return &ValidatorException{Errors: errors}
}

// Error implements error.
func (e *ValidatorException) Error() string {
	if len(e.Errors) == 0 {
		return "Validation failed"
	}

	var b strings.Builder
	b.WriteString("Validation failed:\n")
	for _, err := range e.Errors {
		b.WriteString(" -- ")
		b.WriteString(err.Field)
		b.WriteString(": ")
		b.WriteString(err.Message)
		b.WriteString(";\n")
	}
	return strings.TrimSuffix(b.String(), "\n")
}

// HasErrors returns true if there are validation errors.
func (e *ValidatorException) HasErrors() bool {
	return len(e.Errors) > 0
}
