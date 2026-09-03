defmodule AppStore.API.RefundHistoryTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.RefundHistory

  describe "get_refund_history/3" do
    test "gets refund history without a revision", %{bypass: bypass, app_store: app_store} do
      expected_body = %{signedTransactions: [], revision: "rev"} |> Jason.encode!()

      Bypass.expect_once(bypass, "GET", "/inApps/v2/refund/lookup/the-transaction-id", fn conn ->
        assert conn.query_string === ""
        Plug.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        RefundHistory.get_refund_history(app_store.api_config, "token", "the-transaction-id")

      assert status === 200
      assert body === expected_body
    end
  end

  describe "get_refund_history/4" do
    test "gets refund history with a revision", %{bypass: bypass, app_store: app_store} do
      expected_body = %{signedTransactions: [], revision: "rev2"} |> Jason.encode!()

      Bypass.expect_once(bypass, "GET", "/inApps/v2/refund/lookup/the-transaction-id", fn conn ->
        assert conn.query_string === "revision=rev"
        Plug.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        RefundHistory.get_refund_history(
          app_store.api_config,
          "token",
          "the-transaction-id",
          "rev"
        )

      assert status === 200
      assert body === expected_body
    end
  end
end
