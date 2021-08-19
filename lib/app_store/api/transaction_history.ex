defmodule AppStore.API.TransactionHistory do
  @moduledoc """
  The module for Transaction History
  """

  alias AppStore.HTTPClient

  @type original_transaction_id :: String.t()
  @type revision :: String.t() | nil

  @path_prefix "/inApps/v1/history"

  @doc """
  Get a customer’s transaction history, including all of their in-app purchases in your app.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get_transaction_history
  """
  @spec get_transaction_history(AppStore.t(), original_transaction_id, revision) ::
          {:error, AppStore.Error.t()} | {:ok, AppStore.Response.t()}
  def get_transaction_history(%AppStore{} = app_store, original_transaction_id, revision \\ nil) do
    do_get_transaction_history(%AppStore{} = app_store, original_transaction_id, revision)
  end

  defp do_get_transaction_history(%AppStore{} = app_store, original_transaction_id, "") do
    do_get_transaction_history(%AppStore{} = app_store, original_transaction_id, nil)
  end

  defp do_get_transaction_history(%AppStore{} = app_store, original_transaction_id, nil) do
    path = "#{@path_prefix}/#{original_transaction_id}"

    HTTPClient.get(app_store, path)
  end

  defp do_get_transaction_history(%AppStore{} = app_store, original_transaction_id, revision) do
    query = %{revision: revision}

    query_string = URI.encode_query(query)

    path = "#{@path_prefix}/#{original_transaction_id}?#{query_string}"

    HTTPClient.get(app_store, path)
  end
end
