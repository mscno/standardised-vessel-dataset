using FluentValidation;
using StandardisedVesselDataset.Models;
using System.Linq;

namespace StandardisedVesselDataset.Validators;

public class GeneralValidator : AbstractValidator<GeneralInformation>
{
    public GeneralValidator()
    {
        RuleFor(g => g.Imo).NotEmpty().WithMessage("{PropertyName} is required");
        RuleFor(g => g.Imo)
            .Must(value => !string.IsNullOrWhiteSpace(value) && value.Length == 7 && value.All(char.IsDigit))
            .WithMessage("{PropertyName} must be seven digits.");
        RuleFor(g => g.ShipName).NotEmpty().WithMessage("{PropertyName} is required");
        RuleFor(g => g.ShipReportingDate).GreaterThan(DateTime.MinValue).WithMessage("{PropertyName} (Datetime) must be greater than default.");
    }
}
