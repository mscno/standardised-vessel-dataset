defmodule SVDTest do
  use ExUnit.Case, async: true

  alias SVD.Extensions.ServiceProvider

  test "creates default service provider" do
    provider = SVD.new_service_provider()
    assert %ServiceProvider{} = provider
  end

  test "creates provider with custom validator" do
    defmodule LocalValidator do
      def validate(_), do: []
    end

    provider = SVD.new_service_provider_with_custom_validator(LocalValidator)
    assert ServiceProvider.get_validator(provider) == LocalValidator
  end
end
