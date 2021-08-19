defmodule AppStore.API.SubscriptionStatusTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.SubscriptionStatus

  describe "get_transaction_history/3" do
    test "Get a history of transactions", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(bypass, "GET", "/inApps/v1/subscriptions/123321", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("server", "daiquiri/3.0.0")
        |> Plug.Conn.resp(401, "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n")
      end)

      {:ok, %AppStore.Response{body: body, status: status}} =
        SubscriptionStatus.get_subscription_statuses(app_store, "123321")

      assert status === 401
      assert body === "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n"
    end
  end
end
