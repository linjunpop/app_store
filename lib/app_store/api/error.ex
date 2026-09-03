defmodule AppStore.API.Error do
  @moduledoc """
  Represents an unsuccessful App Store Server API request.

  API facade calls return this struct in `{:error, error}` tuples. `code`
  identifies the client or server failure category; `detail` contains the
  underlying response information supplied by the configured HTTP client.

  See the [Error Handling](error-handling.html) guide for pattern matching and
  retry guidance.
  """

  @enforce_keys [:code, :detail]
  defstruct [:code, :detail]

  @type t :: %__MODULE__{
          code: atom() | integer(),
          detail: any()
        }

  @type client_error :: %{
          code: :client_error,
          detail: %{
            status: integer(),
            data: map(),
            headers: list()
          }
        }

  @type server_error :: %{
          code: :server_error,
          detail: %{
            status: integer(),
            data: map(),
            headers: list()
          }
        }
end
