if Code.ensure_loaded?(Finch) do
  # Only define this module when Finch exists as an dependency.
  defmodule AppStore.HTTPClient.DefaultClient do
    @moduledoc """
    The default implementation for `AppStore.HTTPClient`. Uses `Finch` as the HTTP client.

    Add the `AppStore.HTTPClient.DefaultClient` to your application's supervision tree:

    ```elixir
    # lib/your_app/application.ex
    def start(_type, _args) do
      children = [
        ...
        {AppStore.HTTPClient.DefaultClient, []}
      ]

      ...
    end
    ```

    Or start it dynamically with `start_link/1`
    """

    @behaviour AppStore.HTTPClient

    @doc false
    def child_spec(opts) do
      %{
        id: __MODULE__,
        start: {__MODULE__, :start_link, [opts]}
      }
    end

    @doc """
    Start an instance of the defalut HTTPClient.

    The following options will be passed to the `Finch.start_link/1`:

    ```elixir
    [
      name: __MODULE__
      pools: %{
        AppStore.API.Config.sandbox_server_url() => [size: 1],
        AppStore.API.Config.production_server_url() => [size: 10]
      }
    ]
    ```

    You override the default options with `opts`, see `Finch.start_link/1` for detail.

    ## Example

    ```elixir
    opts = [
      pools: %{
        AppStore.API.Config.production_server_url() => [size: 30]
      }
    ]

    AppStore.HTTPClient.DefaultClient.start_link(opts)
    ```
    """
    def start_link(opts) do
      opts =
        [
          name: __MODULE__,
          pools: %{
            AppStore.API.Config.sandbox_server_url() => [size: 1],
            AppStore.API.Config.production_server_url() => [size: 10]
          }
        ]
        |> Keyword.merge(opts)

      Finch.start_link(opts)
    end

    @impl AppStore.HTTPClient
    def request(method, uri, body, headers \\ []) do
      request = Finch.build(method, uri, headers, body)

      result = Finch.request(request, __MODULE__)

      with {:ok, %Finch.Response{} = response} <- result do
        {:ok,
         %{
           status: response.status,
           headers: response.headers,
           body: response.body,
           data: nil
         }}
      else
        {:error, error} ->
          {:error,
           %{
             code: :finch_error,
             detail: error
           }}
      end
    end
  end
else
  defmodule AppStore.HTTPClient.DefaultClient do
    @moduledoc """
    HTTP client with dark magic.
    """
    @behaviour AppStore.HTTPClient

    @impl true
    def request(_method, _url, _body, _headers \\ []) do
      raise RuntimeError, """
      Please add `Finch` to your application's dependency or customize your own.

      See documentation for `AppStore` and `AppStore.HTTPClient` for more information.
      """
    end
  end
end
