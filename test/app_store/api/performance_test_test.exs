defmodule AppStore.API.PerformanceTestTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.PerformanceTest

  describe "initiate_performance_test/3" do
    test "initiates a performance test", %{bypass: bypass, app_store: app_store} do
      expected_body = %{requestIdentifier: "req-id"} |> Jason.encode!()

      Passby.expect_once(bypass, "POST", "/inApps/v1/messaging/performanceTest", fn conn ->
        Passby.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        PerformanceTest.initiate_performance_test(app_store.api_config, "token", %{
          transactionId: "the-transaction-id"
        })

      assert status === 200
      assert body === expected_body
    end
  end

  describe "get_performance_test_results/3" do
    test "gets performance test results", %{bypass: bypass, app_store: app_store} do
      expected_body = %{requestIdentifier: "req-id", status: "COMPLETE"} |> Jason.encode!()

      Passby.expect_once(
        bypass,
        "GET",
        "/inApps/v1/messaging/performanceTest/result/req-id",
        fn conn -> Passby.Conn.resp(conn, 200, expected_body) end
      )

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        PerformanceTest.get_performance_test_results(app_store.api_config, "token", "req-id")

      assert status === 200
      assert body === expected_body
    end
  end
end
