if Code.ensure_loaded?(Jason) do
  # Only define this module when Finch exists as an dependency.
  defmodule AppStore.JSON.DefaultCoder do
    @moduledoc """
    The default implementation for `AppStore.JSON`. Uses `Jason` as the JSON encoder & decoder.
    """

    @behaviour AppStore.JSON

    @impl true
    def encode!(data) do
      Jason.encode!(data)
    end

    @impl true
    def decode!(str) do
      Jason.decode!(str)
    end
  end
else
  defmodule AppStore.JSON.DefaultCoder do
    @moduledoc """
    HTTP client with dark magic.
    """
    @behaviour AppStore.JSON

    @impl true
    def encode!(data) do
      fail!()
    end

    def decode!(data) do
      fail!()
    end

    defp fail! do
      raise RuntimeError, """
      Please add `Jason` to your application's dependency or customize your own.

      See documentation for `AppStore` and `AppStore.JSON` for more information.
      """
    end
  end
end
