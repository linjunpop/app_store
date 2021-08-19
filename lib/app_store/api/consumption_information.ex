defmodule AppStore.API.ConsumptionInformation do
  @moduledoc """
  The module for Consumption Information
  """

  alias AppStore.HTTPClient

  @type original_transaction_id :: String.t()

  @path_prefix "/inApps/v1/transactions/consumption"

  @doc """
  Send consumption information about a consumable in-app purchase to the App Store, after your server receives a consumption request notification.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/send_consumption_information
  """
  @spec send_consumption_information(AppStore.t(), original_transaction_id, map) ::
          {:error, AppStore.Error.t()} | {:ok, AppStore.Response.t()}
  def send_consumption_information(%AppStore{} = app_store, original_transaction_id, body)
      when is_map(body) do
    path = "#{@path_prefix}/#{original_transaction_id}"

    HTTPClient.put(app_store, path, body)
  end
end
