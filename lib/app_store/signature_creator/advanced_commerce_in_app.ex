defmodule AppStore.SignatureCreator.AdvancedCommerceInApp do
  @moduledoc """
  Creates the signed JWS used to submit requests to the Advanced Commerce API.

  Official documentation: [Generating JWS to sign App Store requests
  ](https://developer.apple.com/documentation/storekit/generating-jws-to-sign-app-store-requests)
  """

  alias AppStore.SignatureCreator.JWTSigner

  @audience "advanced-commerce-api"

  @doc """
  Create an Advanced Commerce in-app signed request.

  ## Options

  - `key`: a map with the Key ID and Private key, `%{id: key_id, pem: private_key_pem}`
  - `issuer_id`: Your issuer ID from the Keys page in App Store Connect
  - `bundle_id`: Your app's bundle ID
  - `request`: The Advanced Commerce request body to sign, a plain map
  - `json_coder`: Optional, the module used to encode `request`, default to `AppStore.JSON.DefaultCoder`
  """
  @spec create_signature(AppStore.Token.key(), String.t(), String.t(), map, module) ::
          {:error, atom | keyword} | {:ok, binary, %{optional(binary) => any}}
  def create_signature(
        key,
        issuer_id,
        bundle_id,
        request,
        json_coder \\ AppStore.JSON.DefaultCoder
      )
      when is_map(request) do
    base64_request =
      json_coder
      |> AppStore.JSON.encode!(request)
      |> Base.encode64()

    JWTSigner.sign(key, issuer_id, bundle_id, @audience, %{"request" => base64_request})
  end
end
