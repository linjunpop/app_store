defmodule AppStore.SignedDataVerifierTest do
  use ExUnit.Case, async: true

  alias AppStore.JWSValidation
  alias AppStore.SignedDataVerifier
  alias AppStore.SignedDataVerifier.Config

  import AppStore.Fixtures, only: [apple_jws_response_v2: 0]

  setup do
    {:ok, [_leaf, _intermediate, root]} =
      JWSValidation.get_binary_cert_chain(apple_jws_response_v2())

    {:ok, root_certificate: root}
  end

  describe "verify_and_decode_transaction/2" do
    test "succeeds when bundle id and environment match", %{root_certificate: root} do
      config =
        Config.build(
          root_certificates: [root],
          environment: "Sandbox",
          bundle_id: "com.example"
        )

      assert {:ok, %JOSE.JWT{fields: %{"bundleId" => "com.example"}}} =
               SignedDataVerifier.verify_and_decode_transaction(config, apple_jws_response_v2())
    end

    test "fails when the bundle id does not match", %{root_certificate: root} do
      config =
        Config.build(
          root_certificates: [root],
          environment: "Sandbox",
          bundle_id: "com.other"
        )

      assert {:error, :invalid_app_identifier} =
               SignedDataVerifier.verify_and_decode_transaction(config, apple_jws_response_v2())
    end

    test "fails when the environment does not match", %{root_certificate: root} do
      config =
        Config.build(
          root_certificates: [root],
          environment: "Production",
          bundle_id: "com.example",
          app_apple_id: 1234
        )

      assert {:error, :invalid_environment} =
               SignedDataVerifier.verify_and_decode_transaction(config, apple_jws_response_v2())
    end

    test "fails when the root certificate is untrusted" do
      config =
        Config.build(
          root_certificates: [JWSValidation.default_root_certificate()],
          environment: "Sandbox",
          bundle_id: "com.example"
        )

      assert {:error, :invalid_cert_chain} =
               SignedDataVerifier.verify_and_decode_transaction(config, apple_jws_response_v2())
    end
  end

  describe "verify_and_decode_renewal_info/2" do
    test "only checks the environment", %{root_certificate: root} do
      config =
        Config.build(
          root_certificates: [root],
          environment: "Sandbox",
          bundle_id: "com.other"
        )

      assert {:ok, %JOSE.JWT{}} =
               SignedDataVerifier.verify_and_decode_renewal_info(config, apple_jws_response_v2())
    end
  end

  describe "Config.build/1" do
    test "requires app_apple_id in Production" do
      assert_raise ArgumentError, fn ->
        Config.build(environment: "Production", bundle_id: "com.example")
      end
    end

    test "defaults to the bundled Apple Root CA - G3" do
      config = Config.build(environment: "Sandbox", bundle_id: "com.example")

      assert config.root_certificates == [JWSValidation.default_root_certificate()]
    end
  end
end
