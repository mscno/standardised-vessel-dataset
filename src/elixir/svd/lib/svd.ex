defmodule SVD do
  @moduledoc """
  Standardised Vessel Dataset (SVD) implementation for Elixir.
  """

  alias SVD.Extensions.ServiceProvider

  @spec new_service_provider() :: ServiceProvider.t()
  def new_service_provider, do: ServiceProvider.new()

  @spec new_service_provider_with_custom_validator(module()) :: ServiceProvider.t()
  def new_service_provider_with_custom_validator(validator_module) do
    ServiceProvider.new_with_custom_validator(validator_module)
  end
end
