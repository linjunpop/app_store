defmodule AppStore.ServerNotificationsTest do
  use ExUnit.Case, async: true

  alias AppStore.ServerNotifications
  alias AppStore.SignedDataVerifier.Config

  defp config do
    Config.build(environment: "LocalTesting", bundle_id: "com.example")
  end

  defp request_body(fields) do
    %{signedPayload: signed_jws(fields)}
    |> Jason.encode!()
  end

  defp signed_jws(fields) do
    header = Base.url_encode64(Jason.encode!(%{alg: "ES256", typ: "JWT"}), padding: false)
    payload = Base.url_encode64(Jason.encode!(fields), padding: false)
    "#{header}.#{payload}.signature"
  end

  describe "decode/3" do
    test "decodes the outer notification and verifies nested signed data" do
      transaction_info = %{
        bundleId: "com.example",
        environment: "LocalTesting",
        transactionId: "transaction-1"
      }

      renewal_info = %{environment: "LocalTesting", autoRenewStatus: 1}

      body =
        request_body(%{
          notificationType: "SUBSCRIBED",
          data: %{
            bundleId: "com.example",
            environment: "LocalTesting",
            signedTransactionInfo: signed_jws(transaction_info),
            signedRenewalInfo: signed_jws(renewal_info)
          }
        })

      assert {:ok,
              %ServerNotifications{
                notification: %JOSE.JWT{fields: %{"notificationType" => "SUBSCRIBED"}},
                transaction_info: %JOSE.JWT{fields: %{"transactionId" => "transaction-1"}},
                renewal_info: %JOSE.JWT{fields: %{"autoRenewStatus" => 1}}
              }} = ServerNotifications.decode(config(), body)
    end

    test "allows notifications without nested signed data" do
      body =
        request_body(%{
          notificationType: "DID_RENEW",
          data: %{bundleId: "com.example", environment: "LocalTesting"}
        })

      assert {:ok, %ServerNotifications{transaction_info: nil, renewal_info: nil}} =
               ServerNotifications.decode(config(), body)
    end

    test "returns an error for malformed JSON" do
      assert {:error, :invalid_json} = ServerNotifications.decode(config(), "not-json")
    end

    test "returns an error when signedPayload is missing or invalid" do
      assert {:error, :missing_signed_payload} =
               ServerNotifications.decode(config(), Jason.encode!(%{}))

      assert {:error, :invalid_signed_payload} =
               ServerNotifications.decode(config(), Jason.encode!(%{signedPayload: 123}))
    end

    test "fails when nested signed data is invalid" do
      body =
        request_body(%{
          data: %{
            bundleId: "com.example",
            environment: "LocalTesting",
            signedTransactionInfo: "invalid"
          }
        })

      assert {:error, {:invalid_nested_signed_data, "signedTransactionInfo"}} =
               ServerNotifications.decode(config(), body)
    end
  end

  describe "status helpers" do
    test "recognizes Apple's successful response range" do
      assert ServerNotifications.successful_status?(200)
      assert ServerNotifications.successful_status?(206)
      refute ServerNotifications.successful_status?(207)
    end

    test "recognizes retryable response ranges" do
      assert ServerNotifications.retryable_status?(400)
      assert ServerNotifications.retryable_status?(599)
      refute ServerNotifications.retryable_status?(399)
      refute ServerNotifications.retryable_status?(600)
    end
  end
end
