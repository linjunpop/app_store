# Getting Started

This guide makes a signed request to the App Store Server API. For the complete
endpoint list, see `AppStore.API`.

## Prepare credentials

Create an App Store Connect API key with access to the App Store Server API.
Keep the issuer ID, key ID, bundle ID, and private key PEM available to your
application. Do not commit the private key to source control.

## Start the default HTTP client

`AppStore.HTTPClient.DefaultClient` is a Finch process and must run under your
application supervisor before making requests:

```elixir
children = [
  {AppStore.HTTPClient.DefaultClient, []}
]

Supervisor.start_link(children, strategy: :one_for_one)
```

## Build a client and generate a token

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
```

`AppStore.build/1` uses the production App Store Server API URL by default.
Pass `api: [server_url: ...]` when working against a different server.

## Make a request

Use the API facade with the built API configuration and generated token:

```elixir
case AppStore.API.get_transaction_history(
       app_store.api_config,
       token,
       "original-transaction-id"
     ) do
  {:ok, %AppStore.API.Response{body: body, status: 200}} ->
    signed_transactions = body["signedTransactions"]

  {:error, %AppStore.API.Error{code: code, detail: detail}} ->
    Logger.warning("App Store API request failed: #{inspect({code, detail})}")
end
```

Successful API calls return `{:ok, %AppStore.API.Response{}}`; unsuccessful
calls return `{:error, %AppStore.API.Error{}}`.

## Next steps

- Use `AppStore.SignedDataVerifier` to verify signed transactions and renewal
  information returned by the API.
- Use `AppStore.ServerNotifications` to receive and verify App Store Server
  Notifications V2.
- Configure custom HTTP or JSON implementations through `AppStore.build/1`
  when your application needs a different transport or instrumentation.