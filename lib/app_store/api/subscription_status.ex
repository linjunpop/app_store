defmodule AppStore.API.SubscriptionStatus do
  @moduledoc """
  The module for Subscription Status
  """

  alias AppStore.HTTPClient

  @type original_transaction_id :: String.t()

  @path_prefix "/inApps/v1/subscriptions"

  @doc """
  Get the statuses for all of a customer’s subscriptions in your app.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get_all_subscription_statuses
  """
  @spec get_subscription_statuses(AppStore.t(), original_transaction_id) ::
          {:error, AppStore.Error.t()} | {:ok, AppStore.Response.t()}
  def get_subscription_statuses(%AppStore{} = app_store, original_transaction_id) do
    path = "#{@path_prefix}/#{original_transaction_id}"

    HTTPClient.get(app_store, path)
  end
end
