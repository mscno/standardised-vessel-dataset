# Standardised Vessel Dataset (SVD) Protocol Buffers

This directory contains the Protocol Buffers schema for the SVD type model.

Schema:

- `svd/v1/svd.proto`

The schema is versioned (`v1`) and maps the canonical SVD model used in this repository.

## Generate Code

From the repository root:

```bash
protoc \
  --proto_path=src/protobuf \
  --go_out=. \
  --go_opt=paths=source_relative \
  --csharp_out=. \
  --cpp_out=. \
  src/protobuf/svd/v1/svd.proto
```

You can target only one language by using the corresponding output flag(s).
