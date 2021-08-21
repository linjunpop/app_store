defmodule AppStore do
  @moduledoc """
  [App Store Server API](https://developer.apple.com/documentation/appstoreserverapi) client.
  """

  alias AppStore.{API, Token}

  @version "0.1.0"

  @enforce_keys [:api_config, :token_config]

  defstruct [
    :api_config,
    :token_config
  ]

  @type t :: %__MODULE__{
          api_config: API.Config.t(),
          token_config: Token.Config.t()
        }

  @doc """
  Build the `AppStore` struct.

  ## Options

  - `api`: Optional, a keyword list to concsturct a `AppStore.API.Config`.
    - `server_url`: Optional, the API server URL, default to the value of `AppStore.API.Config.production_server_url/0`
    - `http_client`: Optional, the module used to make HTTP calls, default to `AppStore.HTTPClient.DefaultClient`
    - `json_coder`: Optional, the module used as JSON encoder & decoder, default to `AppStore.JSON.DefaultCoder`
  - `token`: Optional, a keyword list to options to construct a `AppStore.Token.Config`.
    - `json_coder`: Optional, the module used as JSON encoder & decoder, default to `AppStore.JSON.DefaultCoder`

  ## Example

      iex> AppStore.build()
      %AppStore{
        api_config: %AppStore.API.Config{
          http_client: AppStore.HTTPClient.DefaultClient,
          json_coder: AppStore.JSON.DefaultCoder,
          server_url: "https://api.storekit.itunes.apple.com"
        },
        token_config: %AppStore.Token.Config{
          json_coder: AppStore.JSON.DefaultCoder
        }
      }

      iex> AppStore.build([
        api: [
          http_client: YourHTTPClient,
          json_coder: YourJSONCoder,
          server_url: "https://api.storekit.itunes.apple.com"
        ],
        token: [
          json_coder: YourJSONCoder
        ]
      ])
      %AppStore{
        api_config: %AppStore.API.Config{
          http_client: YourHTTPClient,
          json_coder: YourJSONCoder,
          server_url: "https://api.storekit.itunes.apple.com"
        },
        token_config: %AppStore.Token.Config{
          json_coder: YourJSONCoder
        }
      }
  """
  def build(opts \\ []) do
    api_opts = Keyword.get(opts, :api, [])
    token_opts = Keyword.get(opts, :token, [])

    api_config = API.Config.build(api_opts)
    token_config = Token.Config.build(token_opts)

    struct!(__MODULE__,
      api_config: api_config,
      token_config: token_config
    )
  end

  @spec version :: String.t()
  @doc """
  Get current app version
  """
  def version do
    @version
  end
end
