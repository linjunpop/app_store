defmodule AppStore.SignatureCreator.PromotionalOffer do
  @moduledoc """
  Creates the legacy RSA-SHA256 signature required to redeem a promotional offer
  through the original StoreKit 1 promotional offer API.

  Official documentation: [Generating a signature for promotional offers
  ](https://developer.apple.com/documentation/storekit/generating-a-signature-for-promotional-offers)
  """

  # U+2063 (invisible separator) delimits the fields Apple expects in the signed payload.
  @delimiter "\u2063"

  @doc """
  Create a promotional offer signature.

  ## Options

  - `signing_key_pem`: Your private key (PEM), downloaded from App Store Connect
  - `key_id`: Your private key ID from App Store Connect
  - `bundle_id`: Your app's bundle ID
  - `product_id`: The subscription product identifier
  - `offer_id`: The subscription discount identifier
  - `app_account_token`: An optional string value that you define; may be an empty string
  - `nonce`: A one-time UUID value that your server generates for every signature
  - `timestamp`: A timestamp in UNIX time format, in milliseconds; keeps the offer active for 24 hours

  Returns the Base64-encoded signature.
  """
  @spec create_signature(
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          integer
        ) :: String.t()
  def create_signature(
        signing_key_pem,
        key_id,
        bundle_id,
        product_id,
        offer_id,
        app_account_token,
        nonce,
        timestamp
      ) do
    payload =
      Enum.join(
        [
          bundle_id,
          key_id,
          product_id,
          offer_id,
          String.downcase(app_account_token),
          String.downcase(nonce),
          Integer.to_string(timestamp)
        ],
        @delimiter
      )

    private_key = decode_private_key(signing_key_pem)

    payload
    |> :public_key.sign(:sha256, private_key)
    |> Base.encode64()
  end

  defp decode_private_key(pem) do
    pem
    |> :public_key.pem_decode()
    |> List.first()
    |> :public_key.pem_entry_decode()
  end
end
