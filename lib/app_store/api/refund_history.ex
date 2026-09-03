defmodule AppStore.API.RefundHistory do
  @moduledoc """
  The module for Refund History
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type transaction_id :: String.t()
  @type revision :: String.t() | nil

  @path_prefix "/inApps/v2/refund/lookup"

  @doc """
  Get a paginated list of all of a customer’s refunded in-app purchases for your app.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get-refund-history
  """
  @spec get_refund_history(Config.t(), String.t(), transaction_id, revision) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def get_refund_history(%Config{} = api_config, token, transaction_id, revision \\ nil) do
    query = HTTP.build_query(revision: revision)

    path = "#{@path_prefix}/#{transaction_id}"
    path = if query == "", do: path, else: "#{path}?#{query}"

    HTTP.get(api_config, token, path)
  end
end
