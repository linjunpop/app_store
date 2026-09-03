defmodule AppStore.API.AppTransactionTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.AppTransaction

  describe "get_app_transaction_info/3" do
    test "gets app transaction info", %{bypass: bypass, app_store: app_store} do
      expected_body = %{signedAppTransaction: "signed"} |> Jason.encode!()

      Bypass.expect_once(
        bypass,
        "GET",
        "/inApps/v1/transactions/appTransactions/the-transaction-id",
        fn conn -> Plug.Conn.resp(conn, 200, expected_body) end
      )

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        AppTransaction.get_app_transaction_info(
          app_store.api_config,
          "token",
          "the-transaction-id"
        )

      assert status === 200
      assert body === expected_body
    end
  end
end
