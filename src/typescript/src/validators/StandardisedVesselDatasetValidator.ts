import { asObject, readProperty } from "../runtime/types";
import { GeneralValidator } from "./GeneralValidator";
import { ValidationError } from "./ValidationError";

export class StandardisedVesselDatasetValidator {
  private readonly generalValidator: GeneralValidator;

  public constructor(generalValidator: GeneralValidator = new GeneralValidator()) {
    this.generalValidator = generalValidator;
  }

  public validate(dataset: unknown): ValidationError[] {
    const datasetObject = asObject(dataset);
    if (datasetObject === null) {
      return [{ field: "SVD", message: "SVD cannot be nil", value: dataset }];
    }

    const general = readProperty(datasetObject, "general");
    const generalObject = asObject(general);
    if (generalObject === null) {
      return [{ field: "General", message: "General is required", value: general }];
    }

    return this.generalValidator.validate(generalObject);
  }
}
