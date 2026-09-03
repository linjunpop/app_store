defmodule AppStore.API.SubscriptionRenewalExtension do
  @moduledoc """
  The module for extending subscription renewal dates
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type original_transaction_id :: String.t()
  @type product_id :: String.t()
  @type request_identifier :: String.t()

  @path_prefix "/inApps/v1/subscriptions/extend"

  @doc """
  Extend the renewal date of a customer’s active subscription.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/extend-a-subscription-renewal-date
  """
  @spec extend_subscription_renewal_date(Config.t(), String.t(), original_transaction_id, map) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def extend_subscription_renewal_date(
        %Config{} = api_config,
        token,
        original_transaction_id,
        body
      )
      when is_map(body) do
    path = "#{@path_prefix}/#{original_transaction_id}"

    HTTP.put(api_config, token, path, body)
  end

  @doc """
  Extend the renewal date for all of your active subscribers.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/extend-subscription-renewal-dates-for-all-active-subscribers
  """
  @spec extend_renewal_date_for_all_active_subscribers(Config.t(), String.t(), map) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def extend_renewal_date_for_all_active_subscribers(%Config{} = api_config, token, body)
      when is_map(body) do
    HTTP.post(api_config, token, "#{@path_prefix}/mass", body)
  end

  @doc """
  Check the status of a request that extends the renewal date to all eligible subscribers.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/get-status-of-subscription-renewal-date-extensions
  """
  @spec get_status_of_subscription_renewal_date_extensions(
          Config.t(),
          String.t(),
          request_identifier,
          product_id
        ) :: {:error, Error.t()} | {:ok, Response.t()}
  def get_status_of_subscription_renewal_date_extensions(
        %Config{} = api_config,
        token,
        request_identifier,
        product_id
      ) do
    path = "#{@path_prefix}/mass/#{product_id}/#{request_identifier}"

    HTTP.get(api_config, token, path)
  end
end
