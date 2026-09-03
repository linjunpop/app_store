defmodule AppStore.SignatureCreator.AdvancedCommerceInAppTest do
  use ExUnit.Case

  alias AppStore.SignatureCreator.AdvancedCommerceInApp

  @key_pem ~s"""
  -----BEGIN PRIVATE KEY-----
  MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgBN3rztoRWmc8v+yi
  R6iigfMkLLWHko+/mn6mpYmwMi+hRANCAARGKbTQuKR4r3ohsAI8W+1PvQE6HwUB
  xF8kf7wO9oSY0n7nCH/97UTON/HZTlsTycRNP7kbr6esvorsx4ZFtYSp
  -----END PRIVATE KEY------
  """

  @key %{id: "keyId", pem: @key_pem}

  describe "create_signature/4" do
    test "signs an arbitrary request map" do
      {:ok, token, claims} =
        AdvancedCommerceInApp.create_signature(@key, "issuerId", "bundleId", %{
          "testValue" => "testValue"
        })

      assert {:ok, %{"kid" => "keyId", "alg" => "ES256", "typ" => "JWT"}} =
               Joken.peek_header(token)

      assert claims["iss"] === "issuerId"
      assert claims["iat"]
      refute Map.has_key?(claims, "exp")
      assert claims["aud"] === "advanced-commerce-api"
      assert claims["bid"] === "bundleId"
      assert claims["nonce"]

      assert claims["request"]
             |> Base.decode64!()
             |> Jason.decode!() === %{"testValue" => "testValue"}
    end
  end
end
