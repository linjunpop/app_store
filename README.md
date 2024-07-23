# App Store

[App Store Server API](https://developer.apple.com/documentation/appstoreserverapi) client.

## Installation

The package can be installed
by adding `app_store` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:app_store, "~> 0.2.1"}
  ]
end
```

## Usage

Add the default HTTP client `AppStore.HTTPClient.DefaultClient` to the application's supervision tree:

```elixir
# lib/your_app/application.ex
def start(_type, _args) do
  children = [
    ...
    {AppStore.HTTPClient.DefaultClient, []}
  ]

  ...
end
```

Build the client:

```elixir
iex> app_store = AppStore.build()

%AppStore{
  api_config: %AppStore.API.Config{
    http_client: AppStore.HTTPClient.DefaultClient,
    json_coder: AppStore.JSON.DefaultCoder,
    server_url: "https://api.storekit.itunes.apple.com"
  },
  token_config: %AppStore.Token.Config{
    json_coder: AppStore.JSON.DefaultCoder
  }
}
```

Generate a token:

```elixir
iex> token = AppStore.Token.generate_token(
  "57246542-96fe-1a63-e053-0824d011072a",
  "com.example.testbundleid2021",
  %{
    id: "2X9R4HXF34",
    pem: "-----BEGIN PRIVATE KEY----- ..."
  }
)

"eyJhbGciOiJFUzI1NiIsImtpZCI6IjJYOVI0SFhGMzQiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhcHBzdG9yZWNvbm5lY3QtdjEiLCJiaWQiOiJjb20uZXhhbXBsZS50ZXN0YnVuZGxlaWQyMDIxIiwiZXhwIjoxNjI5NTA2MjQwLCJpYXQiOjE2Mjk1MDI3MDAsImlzcyI6IjU3MjQ2NTQyLTk2ZmUtMWE2My1lMDUzLTA4MjRkMDExMDcyYSIsIm5vbmNlIjoiMnFlaWc0a2wxOTQ0aHFhbmVzMDAwMGMxIn0.gYa_A7J6a6UAyBTAohf4gj28jT0k-OX1CW8cwsVGb4EewEm3owdsv6iWvzt7SutCndCBg5hPfNFWuZ0Au20HxA"
```

Get transactions history:

```elixir
iex> {:ok, %AppStore.API.Response{body: body, status: status}} =
  AppStore.API.get_transaction_history(
    app_store.api_config,
    token,
    "the-transaction-id"
  )
```

Please check [https://hexdocs.pm/app_store](https://hexdocs.pm/app_store) for a full documentation.
