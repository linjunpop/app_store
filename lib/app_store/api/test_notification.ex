defmodule AppStore.API.TestNotification do
  @moduledoc """
  The module for Test Notification
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @path_prefix "/inApps/v1/notifications/test"

  @doc """
  Send a test notification to the App Store.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/request-a-test-notification
  """
  @spec send_test_notification(Config.t(), String.t()) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def send_test_notification(%Config{} = api_config, token)  do
    HTTP.post(api_config, token, @path_prefix)
  end

  @doc """
  Get the status of a test notification.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get-test-notification-status
  """
  @spec get_test_notification_status(Config.t(), String.t(), String.t()) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def get_test_notification_status(%Config{} = api_config, token, test_notification_token) do
    HTTP.get(api_config, token, "#{@path_prefix}/#{test_notification_token}")
  end
end
