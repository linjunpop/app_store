{:ok, _} = AppStore.HTTPClient.DefaultClient.start_link(pool_size: 2)

ExUnit.start()
