# Signed Data Verification

The App Store Server API returns signed JWS payloads for transactions, renewal
information, app transactions, server notifications, and Retention Messaging
requests. `AppStore.SignedDataVerifier` verifies their certificate chain and
checks the configured app identity and environment before returning a decoded
`JOSE.JWT`.

## Choose the right entry point

Use a verifier function when the application already has a signed JWS value:

```elixir
{:ok, %JOSE.JWT{fields: transaction}} =
  AppStore.SignedDataVerifier.verify_and_decode_transaction(config, signed_transaction)
```

Available functions include `verify_and_decode_transaction/2`,
`verify_and_decode_renewal_info/2`, `verify_and_decode_notification/2`,
`verify_and_decode_app_transaction/2`, and
`verify_and_decode_realtime_request/2`.

For a complete App Store Server Notifications V2 HTTP body, prefer
`AppStore.ServerNotifications.decode/3`; it verifies the outer payload and its
nested signed transaction and renewal information.

## Configure the environment

```elixir
config =
  AppStore.SignedDataVerifier.Config.build(
    environment: "Sandbox",
    bundle_id: "com.example.app"
  )
```

- `"Sandbox"` verifies data issued for the App Store Sandbox environment.
- `"Production"` verifies production data and requires `app_apple_id` in the
  configuration.
- `"Xcode"` and `"LocalTesting"` accept locally issued test payloads. These
  payloads are not App Store-signed, so cryptographic verification is skipped;
  use them only in controlled local development and test environments.

The config defaults to the bundled Apple Root CA G3 certificate. Supplying
`root_certificates` is intended for explicit certificate-root control, such as
tests.

## Handle failures

Verification succeeds as `{:ok, %JOSE.JWT{}}` and returns `{:error, reason}`
otherwise. Common reasons include `:invalid_app_identifier`,
`:invalid_environment`, `:invalid_chain_length`, and
`:verification_failure`. Treat an unsuccessful verification as untrusted data;
do not process its purchase state.