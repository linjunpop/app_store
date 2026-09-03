defmodule AppStore.API.NotificationHistory do
  @moduledoc """
  The module for Notification History
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type pagination_token :: String.t() | nil

  @path_prefix "/inApps/v1/notifications/history"

  @doc """
  Get a customer’s in-app purchase notification history for your app.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get-notification-history
  """
  @spec get_notification_history(Config.t(), String.t(), map, pagination_token) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def get_notification_history(%Config{} = api_config, token, body, pagination_token \\ nil)
      when is_map(body) do
    query = HTTP.build_query(paginationToken: pagination_token)

    path = if query == "", do: @path_prefix, else: "#{@path_prefix}?#{query}"

    HTTP.post(api_config, token, path, body)
  end
end
