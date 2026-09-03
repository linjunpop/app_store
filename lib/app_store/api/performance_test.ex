defmodule AppStore.API.PerformanceTest do
  @moduledoc """
  The module for running retention messaging sandbox performance tests
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type request_id :: String.t()

  @path_prefix "/inApps/v1/messaging/performanceTest"

  @doc """
  Start a sandbox performance test for retention messaging realtime requests.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec initiate_performance_test(Config.t(), String.t(), map) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def initiate_performance_test(%Config{} = api_config, token, body) when is_map(body) do
    HTTP.post(api_config, token, @path_prefix, body)
  end

  @doc """
  Get the results of a sandbox performance test.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec get_performance_test_results(Config.t(), String.t(), request_id) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def get_performance_test_results(%Config{} = api_config, token, request_id) do
    HTTP.get(api_config, token, "#{@path_prefix}/result/#{request_id}")
  end
end
