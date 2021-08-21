defmodule AppStore.API.Response do
  @moduledoc """
  The struct representing the response from API.
  """

  @enforce_keys [:body, :headers, :status]
  defstruct data: nil, body: nil, headers: [], status: nil

  @type t :: %__MODULE__{
          data: map(),
          body: binary(),
          headers: AppStore.HTTPClient.http_headers(),
          status: non_neg_integer()
        }
end
