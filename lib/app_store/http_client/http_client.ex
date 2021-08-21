defmodule AppStore.HTTPClient do
  @moduledoc """
  HTTPClient behaviour for AppStore

  ## Build your own HTTP client:

  ```elixir
  defmodule MyApp.AwesomeHTTPClient do
    @behaviour AppStore.HTTPClient

    @impl true
    def request(method, uri, body, headers \\ []) do
      # request the server
      if success
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

  @type http_method :: :get | :put
  @type http_headers :: [{header_name :: String.t(), header_value :: String.t()}]
  @type http_response :: %{
          data: map(),
          body: binary(),
          headers: http_headers(),
          status: non_neg_integer()
        }
  @type http_error :: %{
          code: atom() | integer(),
          detail: any()
        }

  @callback request(
              method :: http_method,
              uri :: URI.t(),
              body :: String.t(),
              headers :: http_headers
            ) :: {:ok, http_response()} | {:error, http_error}

  @spec perform_request(
          module(),
          String.t(),
          http_method,
          URI.t(),
          nil | String.t() | map()
        ) :: {:ok, http_response()} | {:error, http_error()}
  def perform_request(
        http_client,
        method,
        uri,
        body,
        headers
      ) do
    http_client.request(method, uri, body, headers)
  end
end
