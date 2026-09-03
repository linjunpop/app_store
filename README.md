# App Store

An Elixir client for the [App Store Server API](https://developer.apple.com/documentation/appstoreserverapi).

## Installation

Add `app_store` to your application's dependencies:

```elixir
def deps do
  [
    {:app_store, "~> 0.5.0"}
  ]
end
```

## Quick Start

Start the default HTTP client under your application's supervisor:

```elixir
children = [
  {AppStore.HTTPClient.DefaultClient, []}
]
```

Build the client, generate an App Store Connect API token, and call an endpoint:

```elixir
app_store = AppStore.build()

{:ok, token, _claims} =
  AppStore.Token.generate_token(
    System.fetch_env!("APP_STORE_ISSUER_ID"),
    "com.example.app",
    %{
      id: System.fetch_env!("APP_STORE_KEY_ID"),
      pem: System.fetch_env!("APP_STORE_PRIVATE_KEY")
    }
  )

{:ok, %AppStore.API.Response{body: body, status: 200}} =
  AppStore.API.get_transaction_history(
    app_store.api_config,
    token,
    "original-transaction-id"
  )

signed_transactions = body["signedTransactions"]
```

API calls return `{:ok, %AppStore.API.Response{}}` or
`{:error, %AppStore.API.Error{}}`. Signed responses should be verified before
their purchase data is used.

## Server Notifications

Use the framework-neutral notification decoder with the unmodified HTTP request
body received from Apple:

```elixir
config =
  AppStore.SignedDataVerifier.Config.build(
    environment: "Production",
    bundle_id: "com.example.app",
    app_apple_id: 123_456_789
  )

{:ok, notification} = AppStore.ServerNotifications.decode(config, request_body)
```

The decoder verifies the outer notification and any nested signed transaction
or renewal data.

## Guides

- [Getting started](https://hexdocs.pm/app_store/getting-started.html)
- [Server notifications](https://hexdocs.pm/app_store/server-notifications.html)
- [Signed data verification](https://hexdocs.pm/app_store/signed-data-verification.html)
- [Error handling](https://hexdocs.pm/app_store/error-handling.html)
- [Customizing clients](https://hexdocs.pm/app_store/customizing-clients.html)

See the complete [HexDocs API reference](https://hexdocs.pm/app_store).
