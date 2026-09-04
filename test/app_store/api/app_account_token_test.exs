defmodule AppStore.API.AppAccountTokenTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.AppAccountToken

  describe "set_app_account_token/4" do
    test "sets the app account token", %{bypass: bypass, app_store: app_store} do
      Passby.expect_once(
        bypass,
        "PUT",
        "/inApps/v1/transactions/the-transaction-id/appAccountToken",
        fn conn -> Passby.Conn.resp(conn, 200, "") end
      )

      {:ok, %AppStore.API.Response{status: status}} =
        AppAccountToken.set_app_account_token(
          app_store.api_config,
          "token",
          "the-transaction-id",
          %{appAccountToken: "550e8400-e29b-41d4-a716-446655440000"}
        )

      assert status === 200
    end
  end
end
