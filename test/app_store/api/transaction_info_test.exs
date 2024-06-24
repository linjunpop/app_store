defmodule AppStore.API.TransactionInfoTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.TransactionInfo

  describe "get_transaction_info/3" do
    test "Get info for a specific transaction", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(bypass, "GET", "/inApps/v1/transactions/transaction-id", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("server", "daiquiri/3.0.0")
        |> Plug.Conn.resp(401, "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n")
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        TransactionInfo.get_transaction_info(
          app_store.api_config,
          "token",
          "transaction-id"
        )

      assert status === 401
      assert body === "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n"
    end
  end
end
