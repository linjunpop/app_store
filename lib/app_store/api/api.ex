defmodule AppStore.API do
  @moduledoc """
  The main module to interact with the App Store Server APIs
  """

  alias AppStore.API.{TransactionHistory, SubscriptionStatus, ConsumptionInformation}

  defdelegate get_transaction_history(app_store, original_transaction_id, revision \\ nil),
    to: TransactionHistory

  defdelegate get_subscription_statuses(app_store, original_transaction_id),
    to: SubscriptionStatus

  defdelegate send_consumption_information(app_store, original_transaction_id, body),
    to: ConsumptionInformation
end
