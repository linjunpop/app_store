defmodule AppStore.API.NotificationHistoryTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.NotificationHistory

  describe "get_notification_history/3" do
    test "gets notification history without pagination", %{bypass: bypass, app_store: app_store} do
      expected_body = %{notificationHistory: [], hasMore: false} |> Jason.encode!()

      Passby.expect_once(bypass, "POST", "/inApps/v1/notifications/history", fn conn ->
        assert conn.query_string === ""
        Passby.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        NotificationHistory.get_notification_history(app_store.api_config, "token", %{
          startDate: 1,
          endDate: 2
        })

      assert status === 200
      assert body === expected_body
    end
  end

  describe "get_notification_history/4" do
    test "gets notification history with a pagination token", %{
      bypass: bypass,
      app_store: app_store
    } do
      expected_body = %{notificationHistory: [], hasMore: true} |> Jason.encode!()

      Passby.expect_once(bypass, "POST", "/inApps/v1/notifications/history", fn conn ->
        assert conn.query_string === "paginationToken=token123"
        Passby.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        NotificationHistory.get_notification_history(
          app_store.api_config,
          "token",
          %{startDate: 1, endDate: 2},
          "token123"
        )

      assert status === 200
      assert body === expected_body
    end
  end
end
