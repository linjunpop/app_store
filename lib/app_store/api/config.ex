defmodule AppStore.API.Config do
  @production_server_url "https://api.storekit.itunes.apple.com"
  @sandbox_server_url "https://api.storekit-sandbox.itunes.apple.com"

  defstruct [
    :server_url,
    :http_client,
    :json_coder
  ]

  @type t :: %__MODULE__{
          server_url: String.t(),
          http_client: module(),
          json_coder: module()
        }

  @doc """
  Build the AppStore client, used by functions in module `AppStore.API`

  ## Options

  - `server_url`: Optional, the API server URL, default to the value of `AppStore.API.Config.production_server_url/0`
  - `http_client`: Optional, the module used to make HTTP calls, default to `AppStore.HTTPClient.DefaultClient`
  - `json_coder`: Optional, the module used as JSON encoder & decoder, default to `AppStore.JSON.DefaultCoder`
  """
  @spec build(keyword) :: t()
  def build(opts \\ []) do
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
end
