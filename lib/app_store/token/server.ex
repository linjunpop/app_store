defmodule AppStore.Token.Server do
  @moduledoc """
  A server for `AppStore.Token`, generate and cache token.

  ## Usage

      iex> AppStore.Token.Server.start_link(%{
        issuer_id: "57246542-96fe-1a63-e053-0824d011072a",
        bundle_id: "com.example.testbundleid2021",
        key: %{
          id: "2X9R4HXF34",
          pem: "-----BEGIN PRIVATE KEY----- ... -----END PRIVATE KEY-----"
        }
      })
      {:ok, server}

      iex> AppStore.Token.Server.generate(server)
      {:ok, "token", %{
        ...claims
      }}
  """

  defmodule State do
    @moduledoc """
    The state for `AppStore.Token.Server`.

    """
    @type t :: %__MODULE__{
            token_info: token_info(),
            config: config()
          }

    @type token_info :: %{
            token: binary,
            claims: map
          }

    @type config :: %{issuer_id: binary, bundle_id: binary, key: %{id: binary, pem: binary}}

    defstruct [:token_info, :config]
  end

  use GenServer

  alias AppStore.Token

  # Client

  @doc """
  Start the server.

  ## Example
      iex> AppStore.Token.Server.start_link(%{
        issuer_id: "57246542-96fe-1a63-e053-0824d011072a",
        bundle_id: "com.example.testbundleid2021",
        key: %{
          id: "2X9R4HXF34",
          pem: "-----BEGIN PRIVATE KEY----- ... -----END PRIVATE KEY-----"
        }
      })
      {:ok, #PID<0.328.0>}
  """
  @spec start_link(State.config()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(config) when is_map(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @doc """
  Generate a signed token and cache it for 59 minutes
  per the suggestion on Apple's documentation: [Generating Tokens for API Requests](https://developer.apple.com/documentation/appstoreserverapi/generating_tokens_for_api_requests)

  ## Example
      iex> AppStore.Token.Server.generate(server)
      {:ok,
        "eyJhbGciOiJFUzI1NiIsImtpZCI6IjJYOVI0SFhGMzQiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhcHBzdG9yZWNvbm5lY3QtdjEiLCJiaWQiOiJjb20uZXhhbXBsZS50ZXN0YnVuZGxlaWQyMDIxIiwiZXhwIjoxNjI5NzI1MDYwLCJpYXQiOjE2Mjk3MjE1MjAsImlzcyI6IjU3MjQ2NTQyLTk2ZmUtMWE2My1lMDUzLTA4MjRkMDExMDcyYSIsIm5vbmNlIjoiMnFldXU1bGg4cTlqZzhkaXBnMDAwMDAyIn0.p4-aBtXXQh3QUz1Ok2dpyuWkUiuk2BI9UCIB6AFs8M0eDyrVnEAPkIydVd_CKMN-VeMrsbL06mG6uW_kCx0TaQ",
        %{
          "aud" => "appstoreconnect-v1",
          "bid" => "com.example.testbundleid2021",
          "exp" => 1629725060,
          "iat" => 1629721520,
          "iss" => "57246542-96fe-1a63-e053-0824d011072a",
          "nonce" => "2qeuu5lh8q9jg8dipg000002"
        }
      }
  """
  def generate(pid) do
    GenServer.call(pid, :generate)
  end

  # Server

  @impl GenServer
  def init(args) do
    {:ok,
     %State{
       config: args,
       token_info: nil
     }}
  end

  @impl GenServer
  def handle_call(:generate, _from, %State{config: config, token_info: nil} = state) do
    case Token.generate_token(config.issuer_id, config.bundle_id, config.key) do
      {:ok, new_token, claims} = result ->
        new_state = %State{
          config: config,
          token_info: %{
            token: new_token,
            claims: claims
          }
        }

        {:reply, result, new_state}

      {:error, err} ->
        {:reply, {:error, err}, state}
    end
  end

  def handle_call(:generate, from, %State{config: config, token_info: token_info} = state) do
    token_expires_at =
      token_info.claims["exp"]
      |> DateTime.from_unix!()

    now = DateTime.utc_now()

    case DateTime.compare(now, token_expires_at) do
      :gt ->
        handle_call(:generate, from, %State{config: config, token_info: nil})

      :eq ->
        handle_call(:generate, from, %State{config: config, token_info: nil})

      :lt ->
        {:reply, {:ok, token_info.token, token_info.claims}, state}
    end
  end
end
