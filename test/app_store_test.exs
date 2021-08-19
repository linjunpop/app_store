defmodule AppStoreTest do
  use ExUnit.Case
  doctest AppStore

  test "greets the world" do
    assert AppStore.hello() == :world
  end
end
