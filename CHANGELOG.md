# CHANGELOG

## main

## v0.5.0

- Added the remaining App Store Server API endpoints: subscription renewal date extension
  (`AppStore.API.SubscriptionRenewalExtension`), refund history (`AppStore.API.RefundHistory`),
  order ID lookup (`AppStore.API.OrderLookup`), app transaction info (`AppStore.API.AppTransaction`),
  notification history (`AppStore.API.NotificationHistory`), set app account token
  (`AppStore.API.AppAccountToken`), and finish transaction (`AppStore.API.TransactionFinish`).
- Added Retention Messaging endpoints: images, messages, default message configuration, realtime
  URL configuration, and sandbox performance testing (`AppStore.API.Messaging*`,
  `AppStore.API.PerformanceTest`).
- `AppStore.API.get_transaction_history/5` now uses the current `v2` history endpoint and supports
  the full set of query filters; `AppStore.API.send_consumption_information/4` now uses the current
  `v2` consumption endpoint; `AppStore.API.get_subscription_statuses/4` supports filtering by status.
- Added signature creators: `AppStore.SignatureCreator.PromotionalOffer` (legacy),
  `AppStore.SignatureCreator.PromotionalOfferV2`,
  `AppStore.SignatureCreator.IntroductoryOfferEligibility`, and
  `AppStore.SignatureCreator.AdvancedCommerceInApp`.
- Added `AppStore.ReceiptUtility` for extracting transaction IDs from legacy App Receipts and
  transaction receipts.
- Added `AppStore.SignedDataVerifier` for verifying and decoding signed transactions, renewal info,
  server notifications, app transactions, and Retention Messaging realtime requests, including
  environment, bundle ID, and app Apple ID checks.
- Fixed a misleading parameter name in the `AppStore.API.send_test_notification/2` delegate.

## v0.4.0

- Added Test Notification endpoint support: `AppStore.API.TestNotification`.

## v0.3.1

- Move Public Apple Certificate to jws_validation directory.

## v0.3.0

- Add JWSValidation module to validate Apple's JSON Web Signature (JWS).

## v0.2.1

- Remove unecessary slash from get_transaction_info call.

## v0.2.0

- Remove `nanoid` dependency.
- Added the `AppStore.Token` for token generation.
- Require Elixir 1.15, support Elixir 1.17 and OTP 27.
- Added a call to GET transaction info by transaction ID `AppStore.API.TransactionInfo` (#5)

## v0.1.0

Initial release
