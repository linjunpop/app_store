defmodule AppStore.API.MessagingRealtimeUrlTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.MessagingRealtimeUrl

  describe "configure_realtime_url/3" do
    test "configures the realtime url", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(bypass, "PUT", "/inApps/v1/messaging/realtime/url", fn conn ->
        Plug.Conn.resp(conn, 200, "")
      end)

      {:ok, %AppStore.API.Response{status: status}} =
        MessagingRealtimeUrl.configure_realtime_url(app_store.api_config, "token", %{
          url: "https://example.com",
          environment: "PRODUCTION"
        })

      assert status === 200
    end
  end

  describe "delete_realtime_url/2" do
    test "deletes the realtime url", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(bypass, "DELETE", "/inApps/v1/messaging/realtime/url", fn conn ->
        Plug.Conn.resp(conn, 200, "")
      end)

      {:ok, %AppStore.API.Response{status: status}} =
        MessagingRealtimeUrl.delete_realtime_url(app_store.api_config, "token")

      assert status === 200
    end
  end

  describe "get_realtime_url/2" do
    test "gets the realtime url", %{bypass: bypass, app_store: app_store} do
      expected_body = %{url: "https://example.com", environment: "PRODUCTION"} |> Jason.encode!()

      Bypass.expect_once(bypass, "GET", "/inApps/v1/messaging/realtime/url", fn conn ->
        Plug.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        MessagingRealtimeUrl.get_realtime_url(app_store.api_config, "token")

      assert status === 200
      assert body === expected_body
    end
  end
end
