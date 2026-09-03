defmodule AppStore.API.AppTransaction do
  @moduledoc """
  The module for App Transaction Info
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type transaction_id :: String.t()

  @path_prefix "/inApps/v1/transactions/appTransactions"

  @doc """
  Get information about a customer’s app transaction, identified by any of their transaction IDs.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get-app-transaction-info
  """
  @spec get_app_transaction_info(Config.t(), String.t(), transaction_id) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def get_app_transaction_info(%Config{} = api_config, token, transaction_id) do
    HTTP.get(api_config, token, "#{@path_prefix}/#{transaction_id}")
  end
end
