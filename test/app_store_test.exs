defmodule AppStoreTest do
  use ExUnit.Case
  # doctest AppStore

  test "build a client with default values" do
    app_store = AppStore.build()

    assert app_store == %AppStore{
             api_config: %AppStore.API.Config{
               http_client: AppStore.HTTPClient.DefaultClient,
               json_coder: AppStore.JSON.DefaultCoder,
               server_url: "https://api.storekit.itunes.apple.com"
             },
             token_config: %AppStore.Token.Config{
               json_coder: AppStore.JSON.DefaultCoder
             }
           }
  end
end
