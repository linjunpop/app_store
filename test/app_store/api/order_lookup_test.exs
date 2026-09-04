defmodule AppStore.API.OrderLookupTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.OrderLookup

  describe "look_up_order_id/3" do
    test "looks up an order id", %{bypass: bypass, app_store: app_store} do
      expected_body = %{status: 0, signedTransactions: []} |> Jason.encode!()

      Passby.expect_once(bypass, "GET", "/inApps/v1/lookup/the-order-id", fn conn ->
        Passby.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        OrderLookup.look_up_order_id(app_store.api_config, "token", "the-order-id")

      assert status === 200
      assert body === expected_body
    end
  end
end
