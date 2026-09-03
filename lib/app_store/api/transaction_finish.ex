defmodule AppStore.API.TransactionFinish do
  @moduledoc """
  The module for finishing a transaction
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type transaction_id :: String.t()

  @doc """
  Notify the App Store that your server finished processing a transaction, for
  transactions that require server-side finalization.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/finish-transaction
  """
  @spec finish_transaction(Config.t(), String.t(), transaction_id) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def finish_transaction(%Config{} = api_config, token, transaction_id) do
    HTTP.post(api_config, token, "/inApps/v1/transactions/#{transaction_id}/finish")
  end
end
