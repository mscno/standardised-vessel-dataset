import { StandardisedVesselDatasetValidator } from "../validators/StandardisedVesselDatasetValidator";
import { StandardisedVesselDatasetContent } from "./StandardisedVesselDatasetContent";
import { ensureValidDataset, generateFileName, toXml } from "./helpers";

export class SvdXmlExporter {
  private readonly validator: StandardisedVesselDatasetValidator;

  public constructor(validator: StandardisedVesselDatasetValidator = new StandardisedVesselDatasetValidator()) {
    this.validator = validator;
  }

  public export(dataset: unknown): StandardisedVesselDatasetContent {
    const validDataset = ensureValidDataset(dataset, this.validator);

    return {
      fileName: generateFileName(validDataset, "xml"),
      contentType: "application/xml",
      data: toXml(validDataset),
    };
  }

  public async exportAsync(dataset: unknown): Promise<StandardisedVesselDatasetContent> {
    return this.export(dataset);
  }
}
