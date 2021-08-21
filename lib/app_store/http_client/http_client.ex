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
  app_store =
    AppStore.build(
      api: [
        http_client: MyApp.AwesomeHTTPClient
      ]
    )
  ```

  See `AppStore.HTTPClient.DefaultClient` for a reference implementation.
  """

  alias AppStore.Response
  alias AppStore.Error
  alias AppStore.API.Config

  @type http_method :: :get | :put
  @type http_headers :: [{header_name :: String.t(), header_value :: String.t()}]

  @callback request(
              method :: http_method,
              uri :: URI.t(),
              body :: String.t(),
              headers :: http_headers
            ) :: {:ok, Response.t()} | {:error, Error.t()}

  @spec get(Config.t(), String.t(), String.t()) ::
          {:error, AppStore.Error.t()} | {:ok, AppStore.Response.t()}
  def get(api_config, token, path) do
    perform_request(api_config, token, :get, path, nil)
  end

  @spec put(Config.t(), String.t(), String.t(), nil | binary | map) ::
          {:error, AppStore.Error.t()} | {:ok, AppStore.Response.t()}
  def put(api_config, token, path, body) do
    perform_request(api_config, token, :put, path, body)
  end

  @spec perform_request(
          Config.t(),
          String.t(),
          http_method,
          String.t(),
          nil | String.t() | map()
        ) :: {:ok, Response.t()} | {:error, Error.t()}
  @doc false
  def perform_request(
        %Config{http_client: http_client, json_coder: json_coder, server_url: server_url},
        token,
        method,
        path,
        body
      ) do
    uri = build_uri(server_url, path)
    body = format_body(json_coder, body)
    headers = build_headers(token)

    http_client.request(method, uri, body, headers)
  end

  defp build_headers(token) do
    [
      {"authorization", "Bearer #{token}"},
      {"accept", "application/json"},
      {"content-type", "application/json"},
      {"user-agent", "Elixir:AppStore/#{AppStore.version()}"}
    ]
  end

  defp build_uri(_server_url, path) when is_struct(path, URI) do
    path
  end

  defp build_uri(server_url, path) do
    url = Path.join(server_url, path)

    URI.parse(url)
  end

  defp format_body(_, nil), do: ""

  defp format_body(_, str) when is_binary(str) do
    str
  end

  defp format_body(json_coder, params) when is_map(params) do
    AppStore.JSON.encode!(json_coder, params)
  end
end
