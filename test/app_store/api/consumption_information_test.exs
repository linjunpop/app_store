defmodule AppStore.API.ConsumptionInformationTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.ConsumptionInformation

  describe "send_consumption_information/4" do
    test "sends consumption information", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(
        bypass,
        "PUT",
        "/inApps/v2/transactions/consumption/the-transaction-id",
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
          "the-transaction-id",
          %{}
        )

      assert status === 401
      assert body === "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n"
    end
  end
end
