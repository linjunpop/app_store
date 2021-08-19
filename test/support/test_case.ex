defmodule AppStore.TestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
    end
  end

  setup _tags do
    AppStore.HTTPClient.DefaultClient.start_link(pool_size: 2)

    bypass = Bypass.open()

    app_store =
      AppStore.build(
        signed_token: "the-signed-token",
        server_url: "http://127.0.0.1:#{bypass.port}"
      )

    {:ok, bypass: bypass, app_store: app_store}
  end
end
