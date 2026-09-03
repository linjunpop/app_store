defmodule AppStore.API.SubscriptionStatusTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.SubscriptionStatus

  describe "get_transaction_history/3" do
    test "Get a history of transactions", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(bypass, "GET", "/inApps/v1/subscriptions/the-transaction-id", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("server", "daiquiri/3.0.0")
        |> Plug.Conn.resp(401, "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n")
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        SubscriptionStatus.get_subscription_statuses(
          app_store.api_config,
          "token",
          "the-transaction-id"
        )

      assert status === 401
      assert body === "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n"
    end
  end

  describe "get_subscription_statuses/4" do
    test "filters by status", %{bypass: bypass, app_store: app_store} do
      expected_body = %{data: []} |> Jason.encode!()

      Bypass.expect_once(bypass, "GET", "/inApps/v1/subscriptions/the-transaction-id", fn conn ->
        assert conn.query_string =~ "status=1"
        assert conn.query_string =~ "status=2"

        Plug.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        SubscriptionStatus.get_subscription_statuses(
          app_store.api_config,
          "token",
          "the-transaction-id",
          [1, 2]
        )

      assert status === 200
      assert body === expected_body
    end
  end
end
