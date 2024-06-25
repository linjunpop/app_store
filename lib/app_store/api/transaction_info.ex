defmodule AppStore.API.TransactionInfo do
  @moduledoc """
  The module for Transaction Info
  """

  alias AppStore.API.{Config, Response, Error, HTTP}

  @type transaction_id :: String.t()

  @path_prefix "/inApps/v1/transactions/"

  @doc """
  Get information about a single transaction for your app.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get_transaction_info
  """
  @spec get_transaction_info(Config.t(), String.t(), transaction_id) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def get_transaction_info(%Config{} = api_config, token, transaction_id) do
    path = "#{@path_prefix}/#{transaction_id}"

    HTTP.get(api_config, token, path)
  end
end
