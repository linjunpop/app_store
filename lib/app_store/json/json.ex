defmodule AppStore.JSON do
  @moduledoc """
  JSON behaviour for AppStore

  ## Build your own JSON encoder & decoder:

  ```elixir
  defmodule MyApp.AwesomeJSONCoder do
    @behaviour AppStore.JSON

    @impl true
    def decode!(json_string) do
      Jason.decode!(json_string)
    end

    @impl true
    def encode!(data) do
      Jason.encode!(data)
    end
  end
  ```

  Then Use the custom JSON implementation while building the client:

  ```elixir
  AppStore =
    AppStore.build(
      api: [
        json_coder: MyApp.AwesomeJSONCoder
      ],
      token: [
        json_coder: MyApp.AwesomeJSONCoder
      ]
    )
  ```

  See `AppStore.JSON.DefaultCoder` for a reference implementation.
  """

  @callback encode!(map() | [map()]) :: String.t()
  @callback decode!(String.t()) :: map()

  @doc false
  def encode!(json_coder, data) do
    json_coder.encode!(data)
  end

  @doc false
  def decode!(json_coder, str) do
    json_coder.decode!(str)
  end
end
