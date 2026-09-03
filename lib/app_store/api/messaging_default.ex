defmodule AppStore.API.MessagingDefault do
  @moduledoc """
  The module for configuring the default retention messaging message per product/locale
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type product_id :: String.t()
  @type locale :: String.t()

  @path_prefix "/inApps/v1/messaging/default"

  @doc """
  Configure the default retention messaging message for a product and locale.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec configure_default_message(Config.t(), String.t(), product_id, locale, map) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def configure_default_message(%Config{} = api_config, token, product_id, locale, body)
      when is_map(body) do
    HTTP.put(api_config, token, "#{@path_prefix}/#{product_id}/#{locale}", body)
  end

  @doc """
  Delete the default retention messaging message configuration for a product and locale.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec delete_default_message(Config.t(), String.t(), product_id, locale) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def delete_default_message(%Config{} = api_config, token, product_id, locale) do
    HTTP.delete(api_config, token, "#{@path_prefix}/#{product_id}/#{locale}")
  end

  @doc """
  Get the default retention messaging message configuration for a product and locale.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec get_default_message(Config.t(), String.t(), product_id, locale) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def get_default_message(%Config{} = api_config, token, product_id, locale) do
    HTTP.get(api_config, token, "#{@path_prefix}/#{product_id}/#{locale}")
  end
end
