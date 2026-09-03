defmodule AppStore.SignatureCreator.IntroductoryOfferEligibility do
  @moduledoc """
  Creates the signed JWS used to indicate whether a customer is eligible for an
  introductory offer.

  Official documentation: [Generating JWS to sign App Store requests
  ](https://developer.apple.com/documentation/storekit/generating-jws-to-sign-app-store-requests)
  """

  alias AppStore.SignatureCreator.JWTSigner

  @audience "introductory-offer-eligibility"

  @doc """
  Create an introductory offer eligibility signature.

  ## Options

  - `key`: a map with the Key ID and Private key, `%{id: key_id, pem: private_key_pem}`
  - `issuer_id`: Your issuer ID from the Keys page in App Store Connect
  - `bundle_id`: Your app's bundle ID
  - `product_id`: The unique identifier of the product
  - `allow_introductory_offer`: Whether the customer is eligible for an introductory offer
  - `transaction_id`: Any transaction ID belonging to the customer
  """
  @spec create_signature(
          AppStore.Token.key(),
          String.t(),
          String.t(),
          String.t(),
          boolean,
          String.t()
        ) ::
          {:error, atom | keyword} | {:ok, binary, %{optional(binary) => any}}
  def create_signature(
        key,
        issuer_id,
        bundle_id,
        product_id,
        allow_introductory_offer,
        transaction_id
      ) do
    feature_claims = %{
      "productId" => product_id,
      "allowIntroductoryOffer" => allow_introductory_offer,
      "transactionId" => transaction_id
    }

    JWTSigner.sign(key, issuer_id, bundle_id, @audience, feature_claims)
  end
end
