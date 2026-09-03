defmodule AppStore.SignatureCreator.JWTSigner do
  @moduledoc false

  # Shared ES256 JWT builder for the App Store signature creators. Apple's
  # signed-request JWS payloads never carry an `exp` claim, unlike `AppStore.Token`.

  @encryption_algorithm "ES256"

  @spec sign(AppStore.Token.key(), String.t(), String.t(), String.t(), map) ::
          {:error, atom | keyword} | {:ok, binary, %{optional(binary) => any}}
  def sign(%{id: key_id, pem: pem}, issuer_id, bundle_id, audience, feature_claims) do
    claims =
      feature_claims
      |> Map.merge(%{
        "iss" => issuer_id,
        "iat" => System.os_time(:second),
        "aud" => audience,
        "bid" => bundle_id,
        "nonce" => Joken.generate_jti()
      })

    signer = Joken.Signer.create(@encryption_algorithm, %{"pem" => pem}, %{"kid" => key_id})

    Joken.generate_and_sign(%{}, claims, signer)
  end
end
