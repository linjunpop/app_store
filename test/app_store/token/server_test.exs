defmodule AppStore.Token.ServerTest do
  use ExUnit.Case

  setup do
    issuer_id = "57246542-96fe-1a63-e053-0824d011072a"
    bundle_id = "com.example.testbundleid2021"

    key_id = "2X9R4HXF34"

    key_pem = ~s"""
    -----BEGIN PRIVATE KEY-----
    MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgBN3rztoRWmc8v+yi
    R6iigfMkLLWHko+/mn6mpYmwMi+hRANCAARGKbTQuKR4r3ohsAI8W+1PvQE6HwUB
    xF8kf7wO9oSY0n7nCH/97UTON/HZTlsTycRNP7kbr6esvorsx4ZFtYSp
    -----END PRIVATE KEY-----
    """

    key = %{id: key_id, pem: key_pem}

    {:ok, server} =
      AppStore.Token.Server.start_link(%{
        issuer_id: issuer_id,
        bundle_id: bundle_id,
        key: key
      })

    {:ok, issuer_id: issuer_id, bundle_id: bundle_id, key: key, server: server}
  end

  describe "generate/0" do
    test "generate a token", context do
      {:ok, token, claims} = AppStore.Token.Server.generate(context[:server])

      assert {:ok, %{"kid" => "2X9R4HXF34", "alg" => "ES256", "typ" => "JWT"}} =
               Joken.peek_header(token)

      assert claims["aud"] === "appstoreconnect-v1"
      assert claims["bid"] === context[:bundle_id]
      assert claims["exp"]
      assert claims["iat"]
      assert claims["nonce"]
      assert claims["iss"] === context[:issuer_id]
    end

    test "generate a token in a short time should return the cached one", context do
      {:ok, token, _claims} = AppStore.Token.Server.generate(context[:server])

      {:ok, second_token, _claims} = AppStore.Token.Server.generate(context[:server])

      assert token === second_token
    end
  end
end
