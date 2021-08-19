defmodule AppStore.HTTPClient do
  @moduledoc """
  HTTPClient behaviour for AppStore

  ## Build your own HTTP client:

  ```elixir
  defmodule MyApp.AwesomeHTTPClient do
    @behaviour AppStore.HTTPClient

    @impl true
    def request(method, url, body, headers \\ []) do
      if success
        {:ok,
        %Response{
          status: response.status,
          headers: response.headers,
          body: response.body,
          data: nil
        }}
      else
        {:error, error} ->
          {:error,
            %Error{
              code: :server_error,
              detail: error
            }
          }
      end
    end
  end
  ```

  Then Use the custom HTTP while building the client:

  ```elixir
  app_store_client =
    AppStore.build(
      signed_token: "xxx-yyy-xxx",
      http_client: MyApp.AwesomeHTTPClient
    )
  ```

  See `AppStore.HTTPClient.DefaultClient` for a reference implementation.
  """

  alias AppStore.Response
  alias AppStore.Error

  @type http_method :: :get | :put
  @type http_headers :: [{header_name :: String.t(), header_value :: String.t()}]

  @callback request(
              method :: http_method,
              uri :: URI.t(),
              body :: String.t(),
              headers :: http_headers
            ) :: {:ok, Response.t()} | {:error, Error.t()}

  @spec get(AppStore.t(), String.t()) ::
          {:error, AppStore.Error.t()} | {:ok, AppStore.Response.t()}
  def get(app_store, path) do
    perform_request(app_store, :get, path, nil)
  end

  @spec put(AppStore.t(), binary, nil | binary | map) ::
          {:error, AppStore.Error.t()} | {:ok, AppStore.Response.t()}
  def put(app_store, path, body) do
    perform_request(app_store, :put, path, body)
  end

  @spec perform_request(
          AppStore.t(),
          http_method,
          String.t(),
          nil | String.t() | map()
        ) :: {:ok, Response.t()} | {:error, Error.t()}
  @doc false
  def perform_request(
        %AppStore{http_client: http_client} = app_store,
        method,
        path,
        body
      ) do
    uri = build_uri(app_store, path)
    body = format_body(app_store, body)
    headers = build_headers(app_store)

    http_client.request(method, uri, body, headers)
  end

  defp build_headers(%AppStore{signed_token: signed_token}) do
    [
      {"authorization", "Bearer #{signed_token}"},
      {"accept", "application/json"},
      {"content-type", "application/json"},
      {"user-agent", "Elixir:AppStore/#{AppStore.version()}"}
    ]
  end

  defp build_uri(%AppStore{server_url: server_url}, path) do
    url = Path.join(server_url, path)

    URI.parse(url)
  end

  defp build_uri(_app_store, path) when is_struct(path, URI) do
    path
  end

  defp format_body(_app_store, nil), do: ""

  defp format_body(_app_store, str) when is_binary(str) do
    str
  end

  defp format_body(app_store, params) when is_map(params) do
    AppStore.JSON.encode!(app_store, params)
  end
end
