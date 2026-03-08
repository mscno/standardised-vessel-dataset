using System.Diagnostics;
using System.Globalization;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.DependencyInjection;
using StandardisedVesselDataset.Extensions;
using StandardisedVesselDataset.Exporters.Formats.CSV;
using StandardisedVesselDataset.Exporters.Formats.Json;
using StandardisedVesselDataset.Exporters.Formats.XML;
using StandardisedVesselDataset.Exporters.Models;
using StandardisedVesselDataset.Validators;
using Svd = StandardisedVesselDataset.Models.StandardisedVesselDataset;

return await ProgramEntry.RunAsync();

internal static class ProgramEntry
{
    private static readonly JsonSerializerOptions InputJsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        Converters =
        {
            new LenientTimeSpanJsonConverter(),
        },
    };

    private static readonly JsonSerializerOptions OutputJsonOptions = new()
    {
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
    };

    public static async Task<int> RunAsync()
    {
        try
        {
            var input = await Console.In.ReadToEndAsync();
            if (string.IsNullOrWhiteSpace(input))
            {
                await WriteResponseAsync(new AdapterResponse
                {
                    Error = "empty request",
                });
                return 1;
            }

            var request = JsonSerializer.Deserialize<AdapterRequest>(input, InputJsonOptions);
            if (request is null)
            {
                await WriteResponseAsync(new AdapterResponse
                {
                    Error = "invalid request payload",
                });
                return 1;
            }

            Svd? svd = null;
            if (request.Dataset.ValueKind is not JsonValueKind.Null and not JsonValueKind.Undefined)
            {
                svd = JsonSerializer.Deserialize<Svd>(request.Dataset.GetRawText(), InputJsonOptions);
            }

            var services = new ServiceCollection();
            services.AddSvd();
            await using var provider = services.BuildServiceProvider();

            var jsonExporter = provider.GetRequiredService<ISvdJsonExporter>();
            var xmlExporter = provider.GetRequiredService<ISvdXmlExporter>();
            var csvExporter = provider.GetRequiredService<ISvdCsvExporter>();

            var response = new AdapterResponse();

            if (ShouldRun(request.Operations, "validate"))
            {
                response.Results["validate"] = await RunValidateAsync(svd);
            }

            if (ShouldRun(request.Operations, "export_json"))
            {
                response.Results["export_json"] = await RunExportAsync(svd, jsonExporter.ExportAsync, "application/json");
            }

            if (ShouldRun(request.Operations, "export_xml"))
            {
                response.Results["export_xml"] = await RunExportAsync(svd, xmlExporter.ExportAsync, "application/xml");
            }

            if (ShouldRun(request.Operations, "export_csv"))
            {
                response.Results["export_csv"] = await RunExportAsync(svd, csvExporter.ExportAsync, "text/csv");
            }

            if (ShouldRun(request.Operations, "benchmark"))
            {
                response.Results["benchmark"] = await RunBenchmarkAsync(
                    svd,
                    request.Benchmark?.Iterations ?? 100,
                    jsonExporter,
                    xmlExporter,
                    csvExporter);
            }

            await WriteResponseAsync(response);
            return 0;
        }
        catch (Exception ex)
        {
            await WriteResponseAsync(new AdapterResponse
            {
                Error = ex.Message,
            });
            return 1;
        }
    }

    private static bool ShouldRun(IReadOnlyList<string>? operations, string operation)
    {
        if (operations is null || operations.Count == 0)
        {
            return true;
        }

        return operations.Any(op => string.Equals(op, operation, StringComparison.OrdinalIgnoreCase));
    }

    private static async Task<ValidateResult> RunValidateAsync(Svd? svd)
    {
        if (svd is null)
        {
            return new ValidateResult
            {
                Ok = true,
                Errors =
                [
                    new ValidationIssue
                    {
                        Field = "SVD",
                        Message = "SVD cannot be nil",
                    },
                ],
            };
        }

        var validator = new StandardisedVesselDatasetValidator();
        var validation = await validator.ValidateAsync(svd);

        var errors = validation.Errors
            .Select(err => new ValidationIssue
            {
                Field = err.PropertyName,
                Message = err.ErrorMessage,
            })
            .ToList();

        return new ValidateResult
        {
            Ok = true,
            Errors = errors,
        };
    }

    private static async Task<ExportResult> RunExportAsync(
        Svd? svd,
        Func<Svd, Task<StandardisedVesselDatasetContent>> export,
        string contentType)
    {
        if (svd is null)
        {
            return new ExportResult
            {
                Ok = false,
                Error = "svd cannot be nil",
            };
        }

        try
        {
            var result = await export(svd);
            return new ExportResult
            {
                Ok = true,
                FileName = result.FileName,
                ContentType = contentType,
                Data = Encoding.UTF8.GetString(result.Content),
            };
        }
        catch (Exception ex)
        {
            return new ExportResult
            {
                Ok = false,
                Error = ex.Message,
            };
        }
    }

    private static async Task<BenchmarkResult> RunBenchmarkAsync(
        Svd? svd,
        int iterations,
        ISvdJsonExporter jsonExporter,
        ISvdXmlExporter xmlExporter,
        ISvdCsvExporter csvExporter)
    {
        if (svd is null)
        {
            return new BenchmarkResult
            {
                Ok = false,
                Error = "svd cannot be nil",
            };
        }

        if (iterations <= 0)
        {
            iterations = 100;
        }

        var validator = new StandardisedVesselDatasetValidator();

        var metrics = new Dictionary<string, BenchmarkMetric>
        {
            ["validate"] = await TimeLoopAsync(iterations, async () =>
            {
                var result = await validator.ValidateAsync(svd);
                return result.IsValid;
            }),
            ["export_json"] = await TimeLoopAsync(iterations, async () =>
            {
                await jsonExporter.ExportAsync(svd);
                return true;
            }),
            ["export_xml"] = await TimeLoopAsync(iterations, async () =>
            {
                await xmlExporter.ExportAsync(svd);
                return true;
            }),
            ["export_csv"] = await TimeLoopAsync(iterations, async () =>
            {
                await csvExporter.ExportAsync(svd);
                return true;
            }),
        };

        return new BenchmarkResult
        {
            Ok = true,
            Iterations = iterations,
            Metrics = metrics,
        };
    }

    private static async Task<BenchmarkMetric> TimeLoopAsync(int iterations, Func<Task<bool>> action)
    {
        var sw = Stopwatch.StartNew();
        var errorCount = 0;

        for (var i = 0; i < iterations; i++)
        {
            try
            {
                var ok = await action();
                if (!ok)
                {
                    errorCount++;
                }
            }
            catch
            {
                errorCount++;
            }
        }

        sw.Stop();

        return new BenchmarkMetric
        {
            TotalMs = sw.Elapsed.TotalMilliseconds,
            AvgMs = sw.Elapsed.TotalMilliseconds / iterations,
            ErrorCount = errorCount,
        };
    }

    private static async Task WriteResponseAsync(AdapterResponse response)
    {
        var payload = JsonSerializer.Serialize(response, OutputJsonOptions);
        await Console.Out.WriteAsync(payload);
    }
}

internal sealed class LenientTimeSpanJsonConverter : JsonConverter<TimeSpan>
{
    public override TimeSpan Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Null)
        {
            return TimeSpan.Zero;
        }

        if (reader.TokenType == JsonTokenType.Number)
        {
            if (reader.TryGetInt64(out var nanoseconds))
            {
                return TimeSpan.FromTicks(nanoseconds / 100);
            }

            if (reader.TryGetDouble(out var floatingNanoseconds))
            {
                var ticks = (long)Math.Round(floatingNanoseconds / 100.0, MidpointRounding.AwayFromZero);
                return TimeSpan.FromTicks(ticks);
            }

            throw new JsonException("Invalid numeric value for TimeSpan.");
        }

        if (reader.TokenType == JsonTokenType.String)
        {
            var value = reader.GetString();
            if (string.IsNullOrWhiteSpace(value))
            {
                return TimeSpan.Zero;
            }

            if (TimeSpan.TryParse(value, CultureInfo.InvariantCulture, out var parsed))
            {
                return parsed;
            }

            throw new JsonException($"Invalid TimeSpan value: '{value}'.");
        }

        throw new JsonException($"Unsupported token for TimeSpan: {reader.TokenType}.");
    }

    public override void Write(Utf8JsonWriter writer, TimeSpan value, JsonSerializerOptions options)
    {
        writer.WriteStringValue(value.ToString("c", CultureInfo.InvariantCulture));
    }
}

internal sealed class AdapterRequest
{
    [JsonPropertyName("dataset")]
    public JsonElement Dataset { get; init; }

    [JsonPropertyName("operations")]
    public List<string>? Operations { get; init; }

    [JsonPropertyName("benchmark")]
    public BenchmarkConfig? Benchmark { get; init; }
}

internal sealed class BenchmarkConfig
{
    [JsonPropertyName("iterations")]
    public int Iterations { get; init; }
}

internal sealed class AdapterResponse
{
    [JsonPropertyName("implementation")]
    public string Implementation { get; init; } = "dotnet";

    [JsonPropertyName("results")]
    public Dictionary<string, object> Results { get; init; } = [];

    [JsonPropertyName("error")]
    public string? Error { get; init; }
}

internal sealed class ValidationIssue
{
    [JsonPropertyName("field")]
    public string Field { get; init; } = string.Empty;

    [JsonPropertyName("message")]
    public string Message { get; init; } = string.Empty;
}

internal sealed class ValidateResult
{
    [JsonPropertyName("ok")]
    public bool Ok { get; init; }

    [JsonPropertyName("errors")]
    public List<ValidationIssue>? Errors { get; init; }

    [JsonPropertyName("error")]
    public string? Error { get; init; }
}

internal sealed class ExportResult
{
    [JsonPropertyName("ok")]
    public bool Ok { get; init; }

    [JsonPropertyName("file_name")]
    public string? FileName { get; init; }

    [JsonPropertyName("content_type")]
    public string? ContentType { get; init; }

    [JsonPropertyName("data")]
    public string? Data { get; init; }

    [JsonPropertyName("error")]
    public string? Error { get; init; }
}

internal sealed class BenchmarkMetric
{
    [JsonPropertyName("total_ms")]
    public double TotalMs { get; init; }

    [JsonPropertyName("avg_ms")]
    public double AvgMs { get; init; }

    [JsonPropertyName("error_count")]
    public int ErrorCount { get; init; }
}

internal sealed class BenchmarkResult
{
    [JsonPropertyName("ok")]
    public bool Ok { get; init; }

    [JsonPropertyName("iterations")]
    public int Iterations { get; init; }

    [JsonPropertyName("metrics")]
    public Dictionary<string, BenchmarkMetric>? Metrics { get; init; }

    [JsonPropertyName("error")]
    public string? Error { get; init; }
}
