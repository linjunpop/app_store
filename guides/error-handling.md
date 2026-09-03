# Error Handling

The client has two error contracts: API requests return an `AppStore.API.Error`
struct, while signed-data verification and notification decoding return an atom
or structured reason.

## API request errors

Every API facade function returns either an `AppStore.API.Response` or an
`AppStore.API.Error`:

```elixir
case AppStore.API.get_transaction_info(api_config, token, transaction_id) do
  {:ok, %AppStore.API.Response{status: status, body: body}} ->
    {:ok, status, body}

  {:error, %AppStore.API.Error{code: code, detail: detail}} ->
    Logger.warning("App Store API error: #{inspect({code, detail})}")
    {:error, code}
end
```

The default client distinguishes transport-level `:client_error` and
`:server_error` values. Its `detail` includes the HTTP status, decoded response
data, and headers. Preserve this information in logs or telemetry to diagnose
an API failure.

Retry only transient transport or server failures, with bounded exponential
backoff. Do not automatically retry malformed requests or authorization
failures; correct the request or credentials first. Make any retried write
operation safe to repeat according to the corresponding Apple endpoint.

## Signed data and notification errors

`AppStore.SignedDataVerifier` returns `{:error, reason}` when it cannot verify
a JWS. `AppStore.ServerNotifications.decode/3` also returns reasons such as
`:invalid_json`, `:missing_signed_payload`, and
`{:invalid_nested_signed_data, key}`.

Never process data from an unsuccessful verification. When handling a server
notification, choose an HTTP response that matches whether the failure is
temporary: `AppStore.ServerNotifications.successful_status?/1` recognizes
Apple's `200..206` acknowledgement range, while `retryable_status?/1`
recognizes `400..599` as retry-requesting responses.