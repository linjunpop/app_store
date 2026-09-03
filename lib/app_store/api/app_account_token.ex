defmodule AppStore.API.AppAccountToken do
  @moduledoc """
  The module for setting a transaction's App Account Token
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type original_transaction_id :: String.t()

  @doc """
  Set the app account token value for a purchase the customer makes outside of your app,
  or updates it for an existing purchase.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi/set-app-account-token
  """
  @spec set_app_account_token(Config.t(), String.t(), original_transaction_id, map) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def set_app_account_token(%Config{} = api_config, token, original_transaction_id, body)
      when is_map(body) do
    path = "/inApps/v1/transactions/#{original_transaction_id}/appAccountToken"

    HTTP.put(api_config, token, path, body)
  end
end
