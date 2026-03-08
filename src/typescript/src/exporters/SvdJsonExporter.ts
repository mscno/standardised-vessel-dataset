import { StandardisedVesselDatasetValidator } from "../validators/StandardisedVesselDatasetValidator";
import { StandardisedVesselDatasetContent } from "./StandardisedVesselDatasetContent";
import { ensureValidDataset, generateFileName, toJson } from "./helpers";

export class SvdJsonExporter {
  private readonly validator: StandardisedVesselDatasetValidator;

  public constructor(validator: StandardisedVesselDatasetValidator = new StandardisedVesselDatasetValidator()) {
    this.validator = validator;
  }

  public export(dataset: unknown): StandardisedVesselDatasetContent {
    const validDataset = ensureValidDataset(dataset, this.validator);

    return {
      fileName: generateFileName(validDataset, "json"),
      contentType: "application/json",
      data: toJson(validDataset),
    };
  }

  public async exportAsync(dataset: unknown): Promise<StandardisedVesselDatasetContent> {
    return this.export(dataset);
  }
}
