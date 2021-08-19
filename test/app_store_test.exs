defmodule AppStoreTest do
  use ExUnit.Case
  # doctest AppStore

  test "build a client with default values" do
    assert AppStore.build(signed_token: "123") == %AppStore{
             http_client: AppStore.HTTPClient.DefaultClient,
             json_coder: AppStore.JSON.DefaultCoder,
             server_url: "https://api.storekit.itunes.apple.com",
             signed_token: "123"
           }
  end

  test "build a failed" do
    assert_raise ArgumentError, ~r/Please specify the `signed_token`/, fn ->
      AppStore.build([])
    end
  end
end
