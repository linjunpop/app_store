defmodule AppStore.API.MessagingMessageTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.MessagingMessage

  describe "upload_message/4" do
    test "uploads a message", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(bypass, "PUT", "/inApps/v1/messaging/message/msg-id", fn conn ->
        Plug.Conn.resp(conn, 200, "")
      end)

      {:ok, %AppStore.API.Response{status: status}} =
        MessagingMessage.upload_message(app_store.api_config, "token", "msg-id", %{
          title: "Hello",
          body: "World",
          locale: "en-US"
        })

      assert status === 200
    end
  end

  describe "delete_message/3" do
    test "deletes a message", %{bypass: bypass, app_store: app_store} do
      Bypass.expect_once(bypass, "DELETE", "/inApps/v1/messaging/message/msg-id", fn conn ->
        Plug.Conn.resp(conn, 200, "")
      end)

      {:ok, %AppStore.API.Response{status: status}} =
        MessagingMessage.delete_message(app_store.api_config, "token", "msg-id")

      assert status === 200
    end
  end

  describe "get_message_list/2" do
    test "gets the message list", %{bypass: bypass, app_store: app_store} do
      expected_body = %{messages: []} |> Jason.encode!()

      Bypass.expect_once(bypass, "GET", "/inApps/v1/messaging/message/list", fn conn ->
        Plug.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        MessagingMessage.get_message_list(app_store.api_config, "token")

      assert status === 200
      assert body === expected_body
    end
  end
end
