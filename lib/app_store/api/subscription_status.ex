defmodule AppStore.API.SubscriptionStatus do
  @moduledoc """
  The module for Subscription Status
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type original_transaction_id :: String.t()
  @type status :: 1..5

  @path_prefix "/inApps/v1/subscriptions"

  @doc """
  Get the statuses for all of a customer’s subscriptions in your app.

  `status` optionally filters the results to one or more subscription statuses
  (`1` active, `2` expired, `3` billing retry, `4` billing grace period, `5` revoked).

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get-all-subscription-statuses
  """
  @spec get_subscription_statuses(Config.t(), String.t(), original_transaction_id, [status]) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def get_subscription_statuses(
        %Config{} = api_config,
        token,
        original_transaction_id,
        status \\ []
      ) do
    query = HTTP.build_query(status: status)

    path = "#{@path_prefix}/#{original_transaction_id}"
    path = if query == "", do: path, else: "#{path}?#{query}"

    HTTP.get(api_config, token, path)
  end
end
