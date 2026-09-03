defmodule AppStore.API.TransactionHistory do
  @moduledoc """
  The module for Transaction History
  """

  alias AppStore.API.{Config, Response, Error, HTTP}

  @type original_transaction_id :: String.t()
  @type revision :: String.t() | nil
  @type filters :: [
          start_date: integer(),
          end_date: integer(),
          product_id: [String.t()],
          product_type: [String.t()],
          sort: String.t(),
          subscription_group_identifier: [String.t()],
          in_app_ownership_type: String.t(),
          revoked: boolean()
        ]

  @path_prefix "/inApps/v2/history"

  @doc """
  Get a customer’s transaction history, including all of their in-app purchases in your app.

  `filters` accepts `:start_date`, `:end_date`, `:product_id` (list), `:product_type` (list),
  `:sort`, `:subscription_group_identifier` (list), `:in_app_ownership_type`, `:revoked`.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get-transaction-history
  """
  @spec get_transaction_history(
          Config.t(),
          String.t(),
          original_transaction_id,
          revision,
          filters
        ) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def get_transaction_history(
        %Config{} = api_config,
        token,
        original_transaction_id,
        revision \\ nil,
        filters \\ []
      ) do
    query = build_query(Keyword.merge(filters, revision: normalize(revision)))

    path = "#{@path_prefix}/#{original_transaction_id}"
    path = if query == "", do: path, else: "#{path}?#{query}"

    HTTP.get(api_config, token, path)
  end

  defp build_query(filters) do
    HTTP.build_query(
      revision: filters[:revision],
      startDate: filters[:start_date],
      endDate: filters[:end_date],
      productId: filters[:product_id],
      productType: filters[:product_type],
      sort: filters[:sort],
      subscriptionGroupIdentifier: filters[:subscription_group_identifier],
      inAppOwnershipType: filters[:in_app_ownership_type],
      revoked: filters[:revoked]
    )
  end

  defp normalize(""), do: nil
  defp normalize(revision), do: revision
end
