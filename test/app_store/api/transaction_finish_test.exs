defmodule AppStore.API.TransactionFinishTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.TransactionFinish

  describe "finish_transaction/3" do
    test "finishes a transaction", %{bypass: bypass, app_store: app_store} do
      Passby.expect_once(
        bypass,
        "POST",
        "/inApps/v1/transactions/the-transaction-id/finish",
        fn conn -> Passby.Conn.resp(conn, 200, "") end
      )

      {:ok, %AppStore.API.Response{status: status}} =
        TransactionFinish.finish_transaction(app_store.api_config, "token", "the-transaction-id")

      assert status === 200
    end
  end
end
