defmodule AppStore.API.SubscriptionRenewalExtensionTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.SubscriptionRenewalExtension

  describe "extend_subscription_renewal_date/4" do
    test "extends a single subscription's renewal date", %{bypass: bypass, app_store: app_store} do
      expected_body = %{effectiveDate: 1, success: true} |> Jason.encode!()

      Bypass.expect_once(
        bypass,
        "PUT",
        "/inApps/v1/subscriptions/extend/the-transaction-id",
        fn conn ->
          Plug.Conn.resp(conn, 200, expected_body)
        end
      )

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        SubscriptionRenewalExtension.extend_subscription_renewal_date(
          app_store.api_config,
          "token",
          "the-transaction-id",
          %{extendByDays: 10, extendReasonCode: 1}
        )

      assert status === 200
      assert body === expected_body
    end
  end

  describe "extend_renewal_date_for_all_active_subscribers/3" do
    test "extends renewal dates for all active subscribers", %{
      bypass: bypass,
      app_store: app_store
    } do
      expected_body = %{requestIdentifier: "req-id"} |> Jason.encode!()

      Bypass.expect_once(bypass, "POST", "/inApps/v1/subscriptions/extend/mass", fn conn ->
        Plug.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        SubscriptionRenewalExtension.extend_renewal_date_for_all_active_subscribers(
          app_store.api_config,
          "token",
          %{
            productId: "product",
            extendByDays: 10,
            extendReasonCode: 1,
            requestIdentifier: "req-id"
          }
        )

      assert status === 200
      assert body === expected_body
    end
  end

  describe "get_status_of_subscription_renewal_date_extensions/4" do
    test "gets the mass extension status", %{bypass: bypass, app_store: app_store} do
      expected_body = %{requestIdentifier: "req-id", complete: true} |> Jason.encode!()

      Bypass.expect_once(
        bypass,
        "GET",
        "/inApps/v1/subscriptions/extend/mass/product/req-id",
        fn conn -> Plug.Conn.resp(conn, 200, expected_body) end
      )

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        SubscriptionRenewalExtension.get_status_of_subscription_renewal_date_extensions(
          app_store.api_config,
          "token",
          "req-id",
          "product"
        )

      assert status === 200
      assert body === expected_body
    end
  end
end
