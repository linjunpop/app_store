defmodule AppStore.HTTPClientTest do
  use AppStore.TestCase, async: false

  describe "get/2" do
    test "Get history", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(bypass, "GET", "/", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("server", "daiquiri/3.0.0")
        |> Plug.Conn.resp(401, "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n")
      end)

      {:ok, %AppStore.Response{body: body, status: status}} =
        AppStore.HTTPClient.get(app_store, "/")

      assert status === 401
      assert body === "Unauthenticated\n\nRequest ID: PXYVB35MOBBC5TL6UOXY6DGJGY.0.0\n"
    end
  end
end
