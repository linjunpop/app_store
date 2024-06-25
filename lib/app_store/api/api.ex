defmodule AppStore.API do
  @moduledoc """
  The main module to interact with the App Store Server APIs
  """

  alias AppStore.API.{
    TransactionHistory,
    TransactionInfo,
    SubscriptionStatus,
    ConsumptionInformation
  }

  defdelegate get_transaction_history(
                api_config,
                token,
                original_transaction_id,
                revision \\ nil
              ),
              to: TransactionHistory

  defdelegate get_transaction_info(api_config, token, transaction_id),
    to: TransactionInfo

  defdelegate get_subscription_statuses(api_config, token, original_transaction_id),
    to: SubscriptionStatus

  defdelegate send_consumption_information(api_config, token, original_transaction_id, body),
    to: ConsumptionInformation
end
