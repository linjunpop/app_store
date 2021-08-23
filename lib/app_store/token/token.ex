defmodule AppStore.Token do
  @moduledoc """
  A module to geenrate the signed token for API usage.

  Please also check `AppStore.Token.Server` for a `GenServer` to cache
  """

  @type key :: %{id: String.t(), pem: String.t()}

  @encryption_algorithm "ES256"

  @aud "appstoreconnect-v1"

  @doc """
  Generate the token for API Requests

  Official documentation: [Generating Tokens for API Requests
  ](https://developer.apple.com/documentation/appstoreserverapi/generating_tokens_for_api_requests)

  ## Options

  - `issuer_id`: Your issuer ID from the Keys page in App Store Connect
  - `bundle_id`: Your app’s bundle ID
  - `key`: a map with the Key ID and Private key
    - `id`: Your private key ID from App Store Connect
    - `pem`: Your private API key generated from App Store Connect, please check [Creating API Keys to Use With the App Store Server API
  ](https://developer.apple.com/documentation/appstoreserverapi/creating_api_keys_to_use_with_the_app_store_server_api)

  ## Example

      iex> AppStore.Token.generate_token(
        "57246542-96fe-1a63-e053-0824d011072a",
        "com.example.testbundleid2021",
        %{
          id: "2X9R4HXF34",
          pem: "-----BEGIN PRIVATE KEY----- ..."
        }
      )
      "eyJhbGciOiJFUzI1NiIsImtpZCI6IjJYOVI0SFhGMzQiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhcHBzdG9yZWNvbm5lY3QtdjEiLCJiaWQiOiJjb20uZXhhbXBsZS50ZXN0YnVuZGxlaWQyMDIxIiwiZXhwIjoxNjI5NTA2MjQwLCJpYXQiOjE2Mjk1MDI3MDAsImlzcyI6IjU3MjQ2NTQyLTk2ZmUtMWE2My1lMDUzLTA4MjRkMDExMDcyYSIsIm5vbmNlIjoiMnFlaWc0a2wxOTQ0aHFhbmVzMDAwMGMxIn0.gYa_A7J6a6UAyBTAohf4gj28jT0k-OX1CW8cwsVGb4EewEm3owdsv6iWvzt7SutCndCBg5hPfNFWuZ0Au20HxA"
  """
  @spec generate_token(String.t(), String.t(), key) ::
          {:error, atom | keyword} | {:ok, binary, %{optional(binary) => any}}
  def generate_token(issuer_id, bundle_id, key) do
    claims = %{
      "iss" => issuer_id,
      "iat" => System.os_time(:second),
      # 59 minutes, valid value are < 60 minutes
      "exp" => System.os_time(:second) + 59 * 60,
      "aud" => @aud,
      "nonce" => Joken.generate_jti(),
      "bid" => bundle_id
    }

    signer = build_signer(key)

    token_config = %{}

    Joken.generate_and_sign(token_config, claims, signer)
  end

  defp build_signer(%{id: id, pem: pem}) do
    Joken.Signer.create(@encryption_algorithm, %{"pem" => pem}, %{"kid" => id})
  end
end
