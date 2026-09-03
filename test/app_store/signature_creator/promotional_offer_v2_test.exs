defmodule AppStore.SignatureCreator.PromotionalOfferV2Test do
  use ExUnit.Case

  alias AppStore.SignatureCreator.PromotionalOfferV2

  @key_pem ~s"""
  -----BEGIN PRIVATE KEY-----
  MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgBN3rztoRWmc8v+yi
  R6iigfMkLLWHko+/mn6mpYmwMi+hRANCAARGKbTQuKR4r3ohsAI8W+1PvQE6HwUB
  xF8kf7wO9oSY0n7nCH/97UTON/HZTlsTycRNP7kbr6esvorsx4ZFtYSp
  -----END PRIVATE KEY------
  """

  @key %{id: "keyId", pem: @key_pem}

  describe "create_signature/6" do
    test "creates a signature with a transaction id" do
      {:ok, token, claims} =
        PromotionalOfferV2.create_signature(
          @key,
          "issuerId",
          "bundleId",
          "productId",
          "offerIdentifier",
          "transactionId"
        )

      assert {:ok, %{"kid" => "keyId", "alg" => "ES256", "typ" => "JWT"}} =
               Joken.peek_header(token)

      assert claims["iss"] === "issuerId"
      assert claims["iat"]
      refute Map.has_key?(claims, "exp")
      assert claims["aud"] === "promotional-offer"
      assert claims["bid"] === "bundleId"
      assert claims["nonce"]
      assert claims["productId"] === "productId"
      assert claims["offerIdentifier"] === "offerIdentifier"
      assert claims["transactionId"] === "transactionId"
    end

    test "omits the transaction id when not given" do
      {:ok, _token, claims} =
        PromotionalOfferV2.create_signature(
          @key,
          "issuerId",
          "bundleId",
          "productId",
          "offerIdentifier"
        )

      refute Map.has_key?(claims, "transactionId")
    end
  end
end
