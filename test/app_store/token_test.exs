defmodule AppStore.TokenTest do
  use ExUnit.Case

  describe "generate_token/3" do
    test "generate the token" do
      issuer_id = "57246542-96fe-1a63-e053-0824d011072a"
      bundle_id = "com.example.testbundleid2021"

      key_id = "2X9R4HXF34"

      key_pem = ~s"""
      -----BEGIN EC PRIVATE KEY-----
      MHcCAQEEIBI3HVhGJaXtZ1OV35tiJspGntAnD6LdyTlb8CwqwK7loAoGCCqGSM49
      AwEHoUQDQgAEuxbhw+SLqAfdNDYUpNLfXvUY+kCDF70EidKgBCC1mO5fTzIID2pv
      ZZ5r50TSYbD984DqkGI+QTGzBoX04eBqeg==
      -----END EC PRIVATE KEY-----
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
