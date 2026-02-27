Mix.Task.run("app.start")

defmodule ConformanceAdapter do
  alias SVD.Exporters.Formats.{CSVExporter, JSONExporter, XMLExporter}
  alias SVD.Exporters.StandardisedVesselDatasetContent
  alias SVD.Models
  alias SVD.Validators.{StandardisedVesselDatasetValidator, ValidatorException}

  def run do
    with {:ok, request} <- read_request() do
      dataset = normalize_dataset(Map.get(request, "dataset"))
      operations = Map.get(request, "operations", [])
      benchmark_cfg = Map.get(request, "benchmark", %{})

      results =
        %{}
        |> maybe_put(operations, "validate", fn -> validate(dataset) end)
        |> maybe_put(operations, "export_json", fn -> export(dataset, JSONExporter, "application/json") end)
        |> maybe_put(operations, "export_xml", fn -> export(dataset, XMLExporter, "application/xml") end)
        |> maybe_put(operations, "export_csv", fn -> export(dataset, CSVExporter, "text/csv") end)
        |> maybe_put(operations, "benchmark", fn -> benchmark(dataset, benchmark_cfg) end)

      write_json!(%{"implementation" => "elixir", "results" => results})
    else
      {:error, message} ->
        write_json!(%{"implementation" => "elixir", "results" => %{}, "error" => message})
        System.halt(1)
    end
  end

  defp read_request do
    raw = IO.read(:stdio, :all)

    case Jason.decode(raw) do
      {:ok, request} when is_map(request) -> {:ok, request}
      {:ok, _} -> {:error, "invalid request payload"}
      {:error, reason} -> {:error, "invalid request: #{Exception.message(reason)}"}
    end
  end

  defp normalize_dataset(nil), do: nil

  defp normalize_dataset(dataset) when is_map(dataset) do
    Models.normalize_dataset(dataset)
  end

  defp normalize_dataset(_), do: nil

  defp maybe_put(results, operations, operation, fun) do
    if run_operation?(operations, operation) do
      Map.put(results, operation, fun.())
    else
      results
    end
  end

  defp run_operation?([], _operation), do: true

  defp run_operation?(operations, operation) do
    Enum.any?(operations, fn value ->
      String.downcase(to_string(value)) == String.downcase(operation)
    end)
  end

  defp validate(dataset) do
    errors =
      StandardisedVesselDatasetValidator.validate(dataset)
      |> Enum.map(fn error -> %{"field" => error.field, "message" => error.message} end)

    %{"ok" => true, "errors" => errors}
  end

  defp export(nil, _module, _content_type) do
    %{"ok" => false, "error" => "SVD cannot be nil"}
  end

  defp export(dataset, exporter_module, fallback_content_type) do
    exporter = exporter_module.new(StandardisedVesselDatasetValidator)

    case exporter_module.export_async(exporter, dataset) do
      {:ok, %StandardisedVesselDatasetContent{} = content} ->
        %{
          "ok" => true,
          "file_name" => content.file_name,
          "content_type" => content.content_type || fallback_content_type,
          "data" => content.data
        }

      {:error, %ValidatorException{} = error} ->
        %{"ok" => false, "error" => Exception.message(error)}

      {:error, error} ->
        %{"ok" => false, "error" => format_error(error)}
    end
  end

  defp benchmark(nil, _cfg), do: %{"ok" => false, "error" => "SVD cannot be nil"}

  defp benchmark(dataset, cfg) do
    iterations =
      case Map.get(cfg, "iterations", 100) do
        value when is_integer(value) and value > 0 -> value
        _ -> 100
      end

    metrics = %{
      "validate" =>
        measure(iterations, fn ->
          _ = StandardisedVesselDatasetValidator.validate(dataset)
          :ok
        end),
      "export_json" => measure(iterations, fn -> benchmark_export(dataset, JSONExporter) end),
      "export_xml" => measure(iterations, fn -> benchmark_export(dataset, XMLExporter) end),
      "export_csv" => measure(iterations, fn -> benchmark_export(dataset, CSVExporter) end)
    }

    %{"ok" => true, "iterations" => iterations, "metrics" => metrics}
  end

  defp benchmark_export(dataset, exporter_module) do
    exporter = exporter_module.new(StandardisedVesselDatasetValidator)

    case exporter_module.export_async(exporter, dataset) do
      {:ok, _} -> :ok
      {:error, _} -> :error
    end
  end

  defp measure(iterations, fun) do
    start = System.monotonic_time(:microsecond)

    error_count =
      1..iterations
      |> Enum.reduce(0, fn _, acc ->
        case fun.() do
          :ok -> acc
          _ -> acc + 1
        end
      end)

    total_us = System.monotonic_time(:microsecond) - start
    total_ms = total_us / 1000.0

    %{
      "total_ms" => total_ms,
      "avg_ms" => total_ms / iterations,
      "error_count" => error_count
    }
  end

  defp format_error(error) when is_binary(error), do: error
  defp format_error(error) when is_atom(error), do: Atom.to_string(error)
  defp format_error(error), do: inspect(error)

  defp write_json!(payload) do
    IO.puts(Jason.encode!(payload))
  end
end

ConformanceAdapter.run()
