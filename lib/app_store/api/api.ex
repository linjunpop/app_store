defmodule AppStore.API do
  @moduledoc """
  The primary facade for the App Store Server API.

  Each function accepts an `AppStore.API.Config` and a generated App Store
  Connect API token. Successful calls return `{:ok, %AppStore.API.Response{}}`;
  unsuccessful calls return `{:error, %AppStore.API.Error{}}`.

  Functions are organized by endpoint family in their implementation modules:
  transaction history and details, subscriptions, consumption, notifications,
  order and refund lookup, retention messaging, and performance testing.

  See the [Getting Started](getting-started.html) and
  [Error Handling](error-handling.html) guides for common call patterns.
  """

  alias AppStore.API.{
    TransactionHistory,
    TransactionInfo,
    SubscriptionStatus,
    ConsumptionInformation,
    TestNotification,
    SubscriptionRenewalExtension,
    RefundHistory,
    OrderLookup,
    AppTransaction,
    NotificationHistory,
    AppAccountToken,
    TransactionFinish,
    MessagingImage,
    MessagingMessage,
    MessagingDefault,
    MessagingRealtimeUrl,
    PerformanceTest
  }

  defdelegate get_transaction_history(
                api_config,
                token,
                original_transaction_id,
                revision \\ nil,
                filters \\ []
              ),
              to: TransactionHistory

  defdelegate get_transaction_info(api_config, token, transaction_id),
    to: TransactionInfo

  defdelegate get_subscription_statuses(api_config, token, original_transaction_id, status \\ []),
    to: SubscriptionStatus

  defdelegate send_consumption_information(api_config, token, original_transaction_id, body),
    to: ConsumptionInformation

  defdelegate send_test_notification(api_config, token),
    to: TestNotification

  defdelegate get_test_notification_status(api_config, token, test_notification_token),
    to: TestNotification

  defdelegate extend_subscription_renewal_date(
                api_config,
                token,
                original_transaction_id,
                body
              ),
              to: SubscriptionRenewalExtension

  defdelegate extend_renewal_date_for_all_active_subscribers(api_config, token, body),
    to: SubscriptionRenewalExtension

  defdelegate get_status_of_subscription_renewal_date_extensions(
                api_config,
                token,
                request_identifier,
                product_id
              ),
              to: SubscriptionRenewalExtension

  defdelegate get_refund_history(api_config, token, transaction_id, revision \\ nil),
    to: RefundHistory

  defdelegate look_up_order_id(api_config, token, order_id),
    to: OrderLookup

  defdelegate get_app_transaction_info(api_config, token, transaction_id),
    to: AppTransaction

  defdelegate get_notification_history(api_config, token, body, pagination_token \\ nil),
    to: NotificationHistory

  defdelegate set_app_account_token(api_config, token, original_transaction_id, body),
    to: AppAccountToken

  defdelegate finish_transaction(api_config, token, transaction_id),
    to: TransactionFinish

  defdelegate upload_image(api_config, token, image_identifier, image, image_size \\ nil),
    to: MessagingImage

  defdelegate delete_image(api_config, token, image_identifier),
    to: MessagingImage

  defdelegate get_image_list(api_config, token),
    to: MessagingImage

  defdelegate upload_message(api_config, token, message_identifier, body),
    to: MessagingMessage

  defdelegate delete_message(api_config, token, message_identifier),
    to: MessagingMessage

  defdelegate get_message_list(api_config, token),
    to: MessagingMessage

  defdelegate configure_default_message(api_config, token, product_id, locale, body),
    to: MessagingDefault

  defdelegate delete_default_message(api_config, token, product_id, locale),
    to: MessagingDefault

  defdelegate get_default_message(api_config, token, product_id, locale),
    to: MessagingDefault

  defdelegate configure_realtime_url(api_config, token, body),
    to: MessagingRealtimeUrl

  defdelegate delete_realtime_url(api_config, token),
    to: MessagingRealtimeUrl

  defdelegate get_realtime_url(api_config, token),
    to: MessagingRealtimeUrl

  defdelegate initiate_performance_test(api_config, token, body),
    to: PerformanceTest

  defdelegate get_performance_test_results(api_config, token, request_id),
    to: PerformanceTest
end
