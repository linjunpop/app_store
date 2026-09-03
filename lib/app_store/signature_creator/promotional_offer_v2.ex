defmodule AppStore.SignatureCreator.PromotionalOfferV2 do
  @moduledoc """
  Creates the signed JWS required to redeem a promotional offer (V2).

  Official documentation: [Generating JWS to sign App Store requests
  ](https://developer.apple.com/documentation/storekit/generating-jws-to-sign-app-store-requests)
  """

  alias AppStore.SignatureCreator.JWTSigner

  @audience "promotional-offer"

  @doc """
  Create a promotional offer V2 signature.

  ## Options

  - `key`: a map with the Key ID and Private key, `%{id: key_id, pem: private_key_pem}`
  - `issuer_id`: Your issuer ID from the Keys page in App Store Connect
  - `bundle_id`: Your app's bundle ID
  - `product_id`: The unique identifier of the product
  - `offer_identifier`: The promotional offer identifier set up in App Store Connect
  - `transaction_id`: Optional, but recommended. Any transaction ID belonging to the customer.
  """
  @spec create_signature(
          AppStore.Token.key(),
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          String.t() | nil
        ) ::
          {:error, atom | keyword} | {:ok, binary, %{optional(binary) => any}}
  def create_signature(
        key,
        issuer_id,
        bundle_id,
        product_id,
        offer_identifier,
        transaction_id \\ nil
      ) do
    feature_claims =
      %{"productId" => product_id, "offerIdentifier" => offer_identifier}
      |> put_optional("transactionId", transaction_id)

    JWTSigner.sign(key, issuer_id, bundle_id, @audience, feature_claims)
  end

  defp put_optional(claims, _key, nil), do: claims
  defp put_optional(claims, key, value), do: Map.put(claims, key, value)
end
