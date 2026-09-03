defmodule AppStore.SignatureCreator.PromotionalOfferTest do
  use ExUnit.Case

  alias AppStore.SignatureCreator.PromotionalOffer

  setup do
    private_key = :public_key.generate_key({:rsa, 2048, 65537})
    pem_entry = :public_key.pem_entry_encode(:RSAPrivateKey, private_key)
    pem = :public_key.pem_encode([pem_entry])

    # Erlang's #'RSAPrivateKey'{} record shares modulus/publicExponent with the public key.
    {:RSAPrivateKey, _, modulus, public_exponent, _, _, _, _, _, _, _} = private_key
    public_key = {:RSAPublicKey, modulus, public_exponent}

    {:ok, pem: pem, public_key: public_key}
  end

  describe "create_signature/8" do
    test "creates a valid, verifiable signature", %{pem: pem, public_key: public_key} do
      signature =
        PromotionalOffer.create_signature(
          pem,
          "keyId",
          "bundleId",
          "productId",
          "offerId",
          "appAccountToken",
          "20fba8a0-2b80-4a7d-a17f-85c1854727f8",
          1_698_148_900_000
        )

      assert is_binary(signature)

      expected_payload =
        Enum.join(
          [
            "bundleId",
            "keyId",
            "productId",
            "offerId",
            "appaccounttoken",
            "20fba8a0-2b80-4a7d-a17f-85c1854727f8",
            "1698148900000"
          ],
          "\u2063"
        )

      assert :public_key.verify(
               expected_payload,
               :sha256,
               Base.decode64!(signature),
               public_key
             )
    end
  end
end
