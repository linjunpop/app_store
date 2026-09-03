defmodule AppStore.API.OrderLookup do
  @moduledoc """
  The module for Order ID Lookup
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type order_id :: String.t()

  @path_prefix "/inApps/v1/lookup"

  @doc """
  Get a customer’s in-app purchases from a receipt using the order ID.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/look-up-order-id
  """
  @spec look_up_order_id(Config.t(), String.t(), order_id) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def look_up_order_id(%Config{} = api_config, token, order_id) do
    HTTP.get(api_config, token, "#{@path_prefix}/#{order_id}")
  end
end
