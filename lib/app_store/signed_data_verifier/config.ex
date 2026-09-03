defmodule AppStore.SignedDataVerifier.Config do
  @moduledoc """
  Configuration for `AppStore.SignedDataVerifier`.
  """

  alias AppStore.JWSValidation

  @enforce_keys [:environment, :bundle_id]
  defstruct root_certificates: [JWSValidation.default_root_certificate()],
            enable_online_checks: false,
            environment: nil,
            bundle_id: nil,
            app_apple_id: nil

  @type t :: %__MODULE__{
          root_certificates: [binary()],
          enable_online_checks: boolean(),
          environment: String.t(),
          bundle_id: String.t(),
          app_apple_id: integer() | nil
        }

  @doc """
  Build a `AppStore.SignedDataVerifier.Config`.

  ## Options

  - `environment`: Required, the App Store environment to target for checks, e.g. `"Production"`, `"Sandbox"`
  - `bundle_id`: Required, the app's bundle identifier
  - `app_apple_id`: The app's identifier, required when `environment` is `"Production"`
  - `root_certificates`: Optional, a list of DER-encoded root certificates, defaults to the bundled Apple Root CA - G3
  - `enable_online_checks`: Optional, defaults to `false`. Note: online revocation (OCSP) checking
    is not currently implemented by this library; this option only controls whether the current
    date (rather than the payload's signed date) is used when checking certificate validity periods.
  """
  @spec build(keyword) :: t()
  def build(opts) do
    config = struct!(__MODULE__, opts)

    if config.environment == "Production" and is_nil(config.app_apple_id) do
      raise ArgumentError, "app_apple_id is required when the environment is Production"
    end

    config
  end
end
