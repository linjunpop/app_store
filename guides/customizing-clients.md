# Customizing Clients

`AppStore.build/1` accepts custom HTTP and JSON implementations. The defaults
are `AppStore.HTTPClient.DefaultClient`, backed by Finch, and
`AppStore.JSON.DefaultCoder`, backed by Jason.

## Customize the HTTP client

Implement the `AppStore.HTTPClient` behaviour when an application needs an
alternate transport, request instrumentation, or a test double. Its
`request/4` callback receives the method, URI, serialized body, and headers.
It returns either `{:ok, response}` with `status`, `headers`, `body`, and
`data` keys, or `{:error, error}` with `code` and `detail` keys.

```elixir
app_store =
  AppStore.build(
    api: [http_client: MyApp.HTTPClient]
  )
```

The default HTTP client is a process and must be added to your supervisor. A
custom implementation controls its own lifecycle.

## Customize JSON coding

Implement `AppStore.JSON` to replace encoding and decoding:

```elixir
app_store =
  AppStore.build(
    api: [json_coder: MyApp.JSON],
    token: [json_coder: MyApp.JSON]
  )
```

Configure both API and token JSON coders when one implementation should be
used consistently for requests and JWT construction. The coder must provide
raising `encode!/1` and `decode!/1` functions, matching the behaviour.