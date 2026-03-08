import { StandardisedVesselDatasetValidator } from "../validators/StandardisedVesselDatasetValidator";
import { StandardisedVesselDatasetContent } from "./StandardisedVesselDatasetContent";
import { ensureValidDataset, generateFileName, toCsv } from "./helpers";

export class SvdCsvExporter {
  private readonly validator: StandardisedVesselDatasetValidator;

  public constructor(validator: StandardisedVesselDatasetValidator = new StandardisedVesselDatasetValidator()) {
    this.validator = validator;
  }

  public export(dataset: unknown): StandardisedVesselDatasetContent {
    const validDataset = ensureValidDataset(dataset, this.validator);

    return {
      fileName: generateFileName(validDataset, "csv"),
      contentType: "text/csv",
      data: toCsv(validDataset),
    };
  }

  public async exportAsync(dataset: unknown): Promise<StandardisedVesselDatasetContent> {
    return this.export(dataset);
  }
}
