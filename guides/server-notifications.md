# Server Notifications

App Store Server Notifications V2 are HTTP POST requests whose raw JSON body
contains a `signedPayload`. Use `AppStore.ServerNotifications.decode/3` to
decode the body and verify the outer notification plus its nested transaction
and renewal data.

## Configure verification

Use the same bundle ID and environment configured for the app that receives
the notification. Production verification also requires the numeric App Store
app ID:

```elixir
config =
  AppStore.SignedDataVerifier.Config.build(
    environment: "Production",
    bundle_id: "com.example.app",
    app_apple_id: 123_456_789
  )
```

Use `"Sandbox"` for Sandbox notifications. See the signed-data verification
guide for the full environment rules.

## Decode the raw body

Pass the exact request body received from Apple before transforming or
re-encoding it:

```elixir
case AppStore.ServerNotifications.decode(config, request_body) do
  {:ok, notification} ->
    event = notification.notification.fields
    transaction = notification.transaction_info
    renewal = notification.renewal_info

    process_notification(event, transaction, renewal)
    200

  {:error, reason} ->
    Logger.error("Could not process App Store notification: #{inspect(reason)}")
    500
end
```

The returned struct contains the decoded JSON envelope, the verified outer
notification, and verified nested transaction and renewal JWS values when the
notification includes them. A nested value that cannot be verified causes the
whole operation to fail.

## Acknowledge and process safely

Apple considers status codes from `200` through `206` successful. Check this
with `AppStore.ServerNotifications.successful_status?/1`. Status codes from
`400` through `599` ask Apple to retry; use
`AppStore.ServerNotifications.retryable_status?/1` when adapting this policy to
your HTTP layer.

Persist a stable notification or transaction identifier before performing
side effects. Apple may deliver the same notification more than once, so
processing must be idempotent.

## Test delivery and history

`AppStore.API.send_test_notification/2` requests a test delivery, and
`AppStore.API.get_test_notification_status/3` checks it. Use
`AppStore.API.get_notification_history/4` to retrieve prior deliveries.