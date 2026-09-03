defmodule AppStore.SignatureCreator.IntroductoryOfferEligibilityTest do
  use ExUnit.Case

  alias AppStore.SignatureCreator.IntroductoryOfferEligibility

  @key_pem ~s"""
  -----BEGIN PRIVATE KEY-----
  MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgBN3rztoRWmc8v+yi
  R6iigfMkLLWHko+/mn6mpYmwMi+hRANCAARGKbTQuKR4r3ohsAI8W+1PvQE6HwUB
  xF8kf7wO9oSY0n7nCH/97UTON/HZTlsTycRNP7kbr6esvorsx4ZFtYSp
  -----END PRIVATE KEY------
  """

  @key %{id: "keyId", pem: @key_pem}

  describe "create_signature/5" do
    test "creates an introductory offer eligibility signature" do
      {:ok, token, claims} =
        IntroductoryOfferEligibility.create_signature(
          @key,
          "issuerId",
          "bundleId",
          "productId",
          true,
          "transactionId"
        )

      assert {:ok, %{"kid" => "keyId", "alg" => "ES256", "typ" => "JWT"}} =
               Joken.peek_header(token)

      assert claims["iss"] === "issuerId"
      assert claims["iat"]
      refute Map.has_key?(claims, "exp")
      assert claims["aud"] === "introductory-offer-eligibility"
      assert claims["bid"] === "bundleId"
      assert claims["nonce"]
      assert claims["productId"] === "productId"
      assert claims["allowIntroductoryOffer"] === true
      assert claims["transactionId"] === "transactionId"
    end
  end
end
