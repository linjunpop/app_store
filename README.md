# App Store

[App Store Server API](https://developer.apple.com/documentation/appstoreserverapi) client.

## Installation

The package can be installed
by adding `app_store` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:app_store, "~> 0.1.0"}
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

Build the client

```elixir
app_store =
  AppStore.build(
    signed_token: "the-signed-token",
    server_url: RingCentral.production_server_url()
  )
```

Now you can use functions in `AppStore.API` module to interact with the App Store Server APIs.

Please check [https://hexdocs.pm/app_store](https://hexdocs.pm/app_store) for a full documentation.
