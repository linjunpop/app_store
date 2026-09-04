defmodule AppStore.API.TransactionHistoryTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.TransactionHistory

  describe "get_transaction_history/3" do
    test "Get a history of transactions", %{bypass: bypass, app_store: app_store} do
      Passby.expect_once(bypass, "GET", "/inApps/v2/history/the-transaction-id", fn conn ->
        conn
        |> Passby.Conn.put_resp_header("server", "daiquiri/3.0.0")
        |> Passby.Conn.resp(401, "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n")
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        TransactionHistory.get_transaction_history(
          app_store.api_config,
          "token",
          "the-transaction-id"
        )

      assert status === 401
      assert body === "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n"
    end
  end

  describe "get_transaction_history/5" do
    test "supports filters", %{bypass: bypass, app_store: app_store} do
      expected_body = %{signedTransactions: [], hasMore: false} |> Jason.encode!()

      Passby.expect_once(bypass, "GET", "/inApps/v2/history/the-transaction-id", fn conn ->
        assert conn.query_string =~ "productType=AUTO_RENEWABLE"
        assert conn.query_string =~ "productType=CONSUMABLE"
        assert conn.query_string =~ "sort=ASCENDING"

        Passby.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        TransactionHistory.get_transaction_history(
          app_store.api_config,
          "token",
          "the-transaction-id",
          nil,
          product_type: ["AUTO_RENEWABLE", "CONSUMABLE"],
          sort: "ASCENDING"
        )

      assert status === 200
      assert body === expected_body
    end
  end
end
