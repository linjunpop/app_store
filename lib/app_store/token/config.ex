defmodule AppStore.Token.Config do
  defstruct [
    :json_coder
  ]

  @type t :: %__MODULE__{
          json_coder: module()
        }

  @doc """
  Build the AppStore client, used by functions in module `AppStore.API`

  ## Options

  - `json_coder`: Optional, the module used as JSON encoder & decoder, default to `AppStore.JSON.DefaultCoder`
  """
  def build(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:json_coder, AppStore.JSON.DefaultCoder)

    struct!(__MODULE__, opts)
  end
end
