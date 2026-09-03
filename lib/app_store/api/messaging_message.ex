defmodule AppStore.API.MessagingMessage do
  @moduledoc """
  The module for managing Advanced Commerce retention messaging messages
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type message_identifier :: String.t()

  @path_prefix "/inApps/v1/messaging/message"

  @doc """
  Upload a retention messaging message.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec upload_message(Config.t(), String.t(), message_identifier, map) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def upload_message(%Config{} = api_config, token, message_identifier, body)
      when is_map(body) do
    HTTP.put(api_config, token, "#{@path_prefix}/#{message_identifier}", body)
  end

  @doc """
  Delete a previously uploaded retention messaging message.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec delete_message(Config.t(), String.t(), message_identifier) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def delete_message(%Config{} = api_config, token, message_identifier) do
    HTTP.delete(api_config, token, "#{@path_prefix}/#{message_identifier}")
  end

  @doc """
  Get the list of retention messaging messages you uploaded.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec get_message_list(Config.t(), String.t()) :: {:error, Error.t()} | {:ok, Response.t()}
  def get_message_list(%Config{} = api_config, token) do
    HTTP.get(api_config, token, "#{@path_prefix}/list")
  end
end
