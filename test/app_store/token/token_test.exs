defmodule AppStore.TokenTest do
  use ExUnit.Case

  describe "generate_token/3" do
    test "generate the token" do
      issuer_id = "57246542-96fe-1a63-e053-0824d011072a"
      bundle_id = "com.example.testbundleid2021"

      key_id = "2X9R4HXF34"

      key_pem = ~s"""
      -----BEGIN PRIVATE KEY-----
      MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgBN3rztoRWmc8v+yi
      R6iigfMkLLWHko+/mn6mpYmwMi+hRANCAARGKbTQuKR4r3ohsAI8W+1PvQE6HwUB
      xF8kf7wO9oSY0n7nCH/97UTON/HZTlsTycRNP7kbr6esvorsx4ZFtYSp
      -----END PRIVATE KEY------
      """

      {:ok, token, claims} =
        AppStore.Token.generate_token(issuer_id, bundle_id, %{id: key_id, pem: key_pem})

      assert {:ok, %{"kid" => ^key_id, "alg" => "ES256", "typ" => "JWT"}} =
               Joken.peek_header(token)

      assert claims["aud"] === "appstoreconnect-v1"
      assert claims["bid"] === bundle_id
      assert claims["exp"]
      assert claims["iat"]
      assert claims["nonce"]
      assert claims["iss"] === issuer_id
    end
  end
end
