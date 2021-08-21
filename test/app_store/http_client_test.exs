defmodule AppStore.HTTPClientTest do
  use AppStore.TestCase, async: false

  describe "get/3" do
    test "Get history", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(bypass, "GET", "/test", fn conn ->
        conn
        |> Plug.Conn.put_resp_header("server", "daiquiri/3.0.0")
        |> Plug.Conn.resp(200, "text")
      end)

      {:ok, %{body: body, status: status}} =
        AppStore.HTTPClient.perform_request(
          app_store.api_config.http_client,
          :get,
          URI.encode("http://127.0.0.1:#{bypass.port}/test"),
          nil,
          []
        )

      assert status === 200
      assert body === "text"
    end
  end
end
