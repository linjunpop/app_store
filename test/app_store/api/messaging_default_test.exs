defmodule AppStore.API.MessagingDefaultTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.MessagingDefault

  describe "configure_default_message/5" do
    test "configures the default message", %{bypass: bypass, app_store: app_store} do
      Passby.expect_once(
        bypass,
        "PUT",
        "/inApps/v1/messaging/default/product-id/en-US",
        fn conn ->
          Passby.Conn.resp(conn, 200, "")
        end
      )

      {:ok, %AppStore.API.Response{status: status}} =
        MessagingDefault.configure_default_message(
          app_store.api_config,
          "token",
          "product-id",
          "en-US",
          %{messageIdentifier: "msg-id"}
        )

      assert status === 200
    end
  end

  describe "delete_default_message/4" do
    test "deletes the default message", %{bypass: bypass, app_store: app_store} do
      Passby.expect_once(
        bypass,
        "DELETE",
        "/inApps/v1/messaging/default/product-id/en-US",
        fn conn ->
          Passby.Conn.resp(conn, 200, "")
        end
      )

      {:ok, %AppStore.API.Response{status: status}} =
        MessagingDefault.delete_default_message(
          app_store.api_config,
          "token",
          "product-id",
          "en-US"
        )

      assert status === 200
    end
  end

  describe "get_default_message/4" do
    test "gets the default message", %{bypass: bypass, app_store: app_store} do
      expected_body = %{messageIdentifier: "msg-id", state: "ACTIVE"} |> Jason.encode!()

      Passby.expect_once(
        bypass,
        "GET",
        "/inApps/v1/messaging/default/product-id/en-US",
        fn conn ->
          Passby.Conn.resp(conn, 200, expected_body)
        end
      )

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        MessagingDefault.get_default_message(app_store.api_config, "token", "product-id", "en-US")

      assert status === 200
      assert body === expected_body
    end
  end
end
