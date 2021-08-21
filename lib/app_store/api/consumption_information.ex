defmodule AppStore.API.ConsumptionInformation do
  @moduledoc """
  The module for Consumption Information
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type original_transaction_id :: String.t()

  @path_prefix "/inApps/v1/transactions/consumption"

  @doc """
  Send consumption information about a consumable in-app purchase to the App Store, after your server receives a consumption request notification.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/send_consumption_information
  """
  @spec send_consumption_information(Config.t(), String.t(), original_transaction_id, map) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def send_consumption_information(%Config{} = api_config, token, original_transaction_id, body)
      when is_map(body) do
    path = "#{@path_prefix}/#{original_transaction_id}"

    HTTP.put(api_config, token, path, body)
  end
end
