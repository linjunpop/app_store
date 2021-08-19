defmodule AppStore.Error do
  @moduledoc """
  The struct representing the error from the API.
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
