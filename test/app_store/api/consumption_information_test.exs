defmodule AppStore.API.ConsumptionInformationTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.ConsumptionInformation

  describe "get_transaction_history/3" do
    test "Get a history of transactions", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(
        bypass,
        "PUT",
        "/inApps/v1/transactions/consumption/the-transactin-id",
        fn conn ->
          conn
          |> Plug.Conn.put_resp_header("server", "daiquiri/3.0.0")
          |> Plug.Conn.resp(
            401,
            "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n"
          )
        end
      )

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        ConsumptionInformation.send_consumption_information(
          app_store.api_config,
          "token",
          "the-transactin-id",
          %{}
        )

      assert status === 401
      assert body === "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n"
    end
  end
end
