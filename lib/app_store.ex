defmodule AppStore do
  @moduledoc """
  [App Store Server API](https://developer.apple.com/documentation/appstoreserverapi) client.
  """

  @version "0.1.0"

  @production_server_url "https://api.storekit.itunes.apple.com"
  @sandbox_server_url "https://api.storekit-sandbox.itunes.apple.com"

  defstruct [
    :server_url,
    :signed_token,
    :http_client,
    :json_coder
  ]

  @type t :: %__MODULE__{
          server_url: String.t(),
          signed_token: String.t(),
          http_client: module(),
          json_coder: module()
        }

  @doc """
  Build the AppStore client, used by functions in module `AppStore.API`

  ## Options

  - `signed_token`: Required, the Signed JWT Token. See [Generating Tokens for API Requests](https://developer.apple.com/documentation/appstoreserverapi/generating_tokens_for_api_requests) on how to generate one.
  - `server_url`: Optional, the API server URL, default to the value of `AppStore.production_server_url/0`
  - `http_client`: Optional, the module used to make HTTP calls, default to `AppStore.HTTPClient.DefaultClient`
  - `json_coder`: Optional, the module used as JSON encoder & decoder, default to `AppStore.JSON.DefaultCoder`
  """
  @spec build(keyword) :: t()
  def build([]), do: raise_missing_required_args()
  def build(nil), do: raise_missing_required_args()

  def build(opts) do
    opts =
      opts
      |> Keyword.put_new(:server_url, production_server_url())
      |> Keyword.put_new(:http_client, AppStore.HTTPClient.DefaultClient)
      |> Keyword.put_new(:json_coder, AppStore.JSON.DefaultCoder)

    struct!(__MODULE__, opts)
  end

  @doc """
  Returns the production API server URL: #{@production_server_url}
  """
  @spec production_server_url :: String.t()
  def production_server_url do
    @production_server_url
  end

  @doc """
  Returns the sandbox API server URL: #{@sandbox_server_url}
  """
  @spec sandbox_server_url :: String.t()
  def sandbox_server_url do
    @sandbox_server_url
  end

  @doc """
  Get current app version
  """
  def version do
    @version
  end

  defp raise_missing_required_args do
    raise ArgumentError, ~S"""
    Please specify the `signed_token`.

        iex> AppStore.build(signed_token: "xxx-yyy-xxx")

    Check [Generating Tokens for API Requests](https://developer.apple.com/documentation/appstoreserverapi/generating_tokens_for_api_requests) on instructions to generate one.
    """
  end
end
