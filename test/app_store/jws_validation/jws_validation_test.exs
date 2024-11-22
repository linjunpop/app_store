defmodule AppStore.JWSValidationTest do
  use AppStore.TestCase, async: false

  import Mock

  alias AppStore.JWSValidation

  describe "validate/2" do
    test_with_mock "returns success for a valid JWS",
                   %{},
                   AppStore.JWSValidation,
                   [:passthrough],
                   validate_certificate_chain: fn cert_chain -> {:ok, cert_chain} end do
      assert {:ok,
              %JOSE.JWT{
                fields: %{
                  "bundleId" => "com.example",
                  "environment" => "Sandbox",
                  "signedDate" => 1_672_956_154_000
                }
              }} == JWSValidation.validate(apple_jws_response_v2())
    end

    test_with_mock "returns success for a valid list of JWS",
                   %{},
                   AppStore.JWSValidation,
                   [:passthrough],
                   validate_certificate_chain: fn cert_chain -> {:ok, cert_chain} end do
      assert [
               {:ok,
                %JOSE.JWT{
                  fields: %{
                    "bundleId" => "com.example",
                    "environment" => "Sandbox",
                    "signedDate" => 1_672_956_154_000
                  }
                }},
               {:ok,
                %JOSE.JWT{
                  fields: %{
                    "bundleId" => "com.example",
                    "environment" => "Sandbox",
                    "signedDate" => 1_672_956_154_000
                  }
                }}
             ] == JWSValidation.validate([apple_jws_response_v2(), apple_jws_response_v2()])
    end

    test "returns error for an invalid JWS header" do
      header_without_x5c = %{"alg" => "ES256"}

      assert {:error, :invalid_jws} ==
               JOSE.JWK.generate_key({:ec, :secp256r1})
               |> JOSE.JWS.sign("{}", header_without_x5c)
               |> JOSE.JWS.compact()
               |> JWSValidation.validate()
    end

    test "returns error for a JWS with invalid signature" do
      with_mocks([
        {AppStore.JWSValidation, [:passthrough],
         validate_certificate_chain: fn cert_chain -> {:ok, cert_chain} end},
        {JOSE.JWT, [:passthrough], verify: fn _jwk, _jws -> {false, %JOSE.JWT{}, %JOSE.JWS{}} end}
      ]) do
        assert {:error, :invalid_signature} == JWSValidation.validate(apple_jws_response_v2())
      end
    end

    test "returns error when certificate chain validation fails" do
      with_mock JWSValidation, [:passthrough],
        validate_certificate_chain: fn _cert_chain -> {:error, :invalid_cert_chain} end do
        assert {:error, :invalid_cert_chain} == JWSValidation.validate(apple_jws_response_v2())
      end
    end

    test "returns error when JWS is nil" do
      assert {:error, :invalid_jws} == JWSValidation.validate(nil)
    end

    test "returns error when jws header has a incorrect cert chain" do
      jws_header = %{
        "alg" => "ES256",
        "x5c" => ["wrong_leaf, wrong_raw, wrong_root"]
      }

      assert {:error, :invalid_jws} ==
               JOSE.JWK.generate_key({:ec, :secp256r1})
               |> JOSE.JWS.sign("{}", jws_header)
               |> JOSE.JWS.compact()
               |> JWSValidation.validate()
    end
  end

  describe "validate_certificate_chain/2" do
    setup do
      {:ok, cert_chain} = JWSValidation.get_binary_cert_chain(apple_jws_response_v2())
      {:ok, cert_chain: cert_chain}
    end

    test "returns success for a valid certificate chain", %{
      cert_chain: [_leaf, _int, root] = cert_chain
    } do
      assert {:ok, _pk_info} = JWSValidation.validate_certificate_chain(cert_chain, root)
    end

    test "returns error for an invalid certificate chain", %{cert_chain: cert_chain} do
      assert {:error, :invalid_cert_chain} == JWSValidation.validate_certificate_chain(cert_chain)
    end

    test "returns error when an incomplete certificate chain is provided", %{
      cert_chain: cert_chain
    } do
      assert {:error, :invalid_cert_chain} ==
               JWSValidation.validate_certificate_chain([List.first(cert_chain)])
    end

    test "returns error when an empty certificate chain is provided" do
      assert {:error, :invalid_cert_chain} == JWSValidation.validate_certificate_chain([])
    end
  end

  defp apple_jws_response_v2 do
    "eyJ4NWMiOlsiTUlJQm9EQ0NBVWFnQXdJQkFnSUJDekFLQmdncWhrak9QUVFEQWpCTk1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFR0ExVUVDQXdLUTJGc2FXWnZjbTVwWVRFU01CQUdBMVVFQnd3SlEzVndaWEowYVc1dk1SVXdFd1lEVlFRS0RBeEpiblJsY20xbFpHbGhkR1V3SGhjTk1qTXdNVEEwTVRZek56TXhXaGNOTXpJeE1qTXhNVFl6TnpNeFdqQkZNUXN3Q1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0F3S1EyRnNhV1p2Y201cFlURVNNQkFHQTFVRUJ3d0pRM1Z3WlhKMGFXNXZNUTB3Q3dZRFZRUUtEQVJNWldGbU1Ga3dFd1lIS29aSXpqMENBUVlJS29aSXpqMERBUWNEUWdBRTRyV0J4R21GYm5QSVBRSTB6c0JLekx4c2o4cEQydnFicjB5UElTVXgyV1F5eG1yTnFsOWZoSzhZRUV5WUZWNysrcDVpNFlVU1Ivbzl1UUlnQ1BJaHJLTWZNQjB3Q1FZRFZSMFRCQUl3QURBUUJnb3Foa2lHOTJOa0Jnc0JCQUlUQURBS0JnZ3Foa2pPUFFRREFnTklBREJGQWlFQWtpRVprb0ZNa2o0Z1huK1E5alhRWk1qWjJnbmpaM2FNOE5ZcmdmVFVpdlFDSURKWVowRmFMZTduU0lVMkxXTFRrNXRYVENjNEU4R0pTWWYvc1lSeEVGaWUiLCJNSUlCbHpDQ0FUMmdBd0lCQWdJQkJqQUtCZ2dxaGtqT1BRUURBakEyTVFzd0NRWURWUVFHRXdKVlV6RVRNQkVHQTFVRUNBd0tRMkZzYVdadmNtNXBZVEVTTUJBR0ExVUVCd3dKUTNWd1pYSjBhVzV2TUI0WERUSXpNREV3TkRFMk1qWXdNVm9YRFRNeU1USXpNVEUyTWpZd01Wb3dUVEVMTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnTUNrTmhiR2xtYjNKdWFXRXhFakFRQmdOVkJBY01DVU4xY0dWeWRHbHViekVWTUJNR0ExVUVDZ3dNU1c1MFpYSnRaV1JwWVhSbE1Ga3dFd1lIS29aSXpqMENBUVlJS29aSXpqMERBUWNEUWdBRUZRM2xYMnNxTjlHSXdBaWlNUURRQy9reW5TZ1g0N1J3dmlET3RNWFh2eUtkUWU2Q1BzUzNqbzJ1UkR1RXFBeFdlT2lDcmpsRFdzeXo1d3dkVTBndGFxTWxNQ013RHdZRFZSMFRCQWd3QmdFQi93SUJBREFRQmdvcWhraUc5Mk5rQmdJQkJBSVRBREFLQmdncWhrak9QUVFEQWdOSUFEQkZBaUVBdm56TWNWMjY4Y1JiMS9GcHlWMUVoVDNXRnZPenJCVVdQNi9Ub1RoRmF2TUNJRmJhNXQ2WUt5MFIySkR0eHF0T2pKeTY2bDZWN2QvUHJBRE5wa21JUFcraSIsIk1JSUJYRENDQVFJQ0NRQ2ZqVFVHTERuUjlqQUtCZ2dxaGtqT1BRUURBekEyTVFzd0NRWURWUVFHRXdKVlV6RVRNQkVHQTFVRUNBd0tRMkZzYVdadmNtNXBZVEVTTUJBR0ExVUVCd3dKUTNWd1pYSjBhVzV2TUI0WERUSXpNREV3TkRFMk1qQXpNbG9YRFRNek1ERXdNVEUyTWpBek1sb3dOakVMTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnTUNrTmhiR2xtYjNKdWFXRXhFakFRQmdOVkJBY01DVU4xY0dWeWRHbHViekJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEEwSUFCSFB2d1pmb0tMS2FPclgvV2U0cU9iWFNuYTVUZFdIVlo2aElSQTF3MG9jM1FDVDBJbzJwbHlEQjMvTVZsazJ0YzRLR0U4VGlxVzdpYlE2WmM5VjY0azB3Q2dZSUtvWkl6ajBFQXdNRFNBQXdSUUloQU1USGhXdGJBUU4waFN4SVhjUDRDS3JEQ0gvZ3N4V3B4NmpUWkxUZVorRlBBaUIzNW53azVxMHpjSXBlZnZZSjBNVS95R0dIU1dlejBicTBwRFlVTy9ubUR3PT0iXSwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJlbnZpcm9ubWVudCI6IlNhbmRib3giLCJidW5kbGVJZCI6ImNvbS5leGFtcGxlIiwic2lnbmVkRGF0ZSI6MTY3Mjk1NjE1NDAwMH0.PnHWpeIJZ8f2Q218NSGLo_aR0IBEJvC6PxmxKXh-qfYTrZccx2suGl223OSNAX78e4Ylf2yJCG2N-FfU-NIhZQ"
  end
end
