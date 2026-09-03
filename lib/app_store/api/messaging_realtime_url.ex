defmodule AppStore.API.MessagingRealtimeUrl do
  @moduledoc """
  The module for configuring the retention messaging realtime request URL
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @path_prefix "/inApps/v1/messaging/realtime/url"

  @doc """
  Configure the URL your server uses to receive realtime retention messaging requests.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec configure_realtime_url(Config.t(), String.t(), map) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def configure_realtime_url(%Config{} = api_config, token, body) when is_map(body) do
    HTTP.put(api_config, token, @path_prefix, body)
  end

  @doc """
  Delete the configured realtime retention messaging request URL.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec delete_realtime_url(Config.t(), String.t()) :: {:error, Error.t()} | {:ok, Response.t()}
  def delete_realtime_url(%Config{} = api_config, token) do
    HTTP.delete(api_config, token, @path_prefix)
  end

  @doc """
  Get the configured realtime retention messaging request URL.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec get_realtime_url(Config.t(), String.t()) :: {:error, Error.t()} | {:ok, Response.t()}
  def get_realtime_url(%Config{} = api_config, token) do
    HTTP.get(api_config, token, @path_prefix)
  end
end
