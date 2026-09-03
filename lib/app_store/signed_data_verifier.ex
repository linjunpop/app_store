defmodule AppStore.SignedDataVerifier do
  @moduledoc """
  Verifies and decodes App Store signed data: transactions, renewal info,
  server notifications, app transactions, and Retention Messaging realtime requests.

  ## Example

      config =
        AppStore.SignedDataVerifier.Config.build(
          environment: "Sandbox",
          bundle_id: "com.example"
        )

      {:ok, %JOSE.JWT{fields: transaction}} =
        AppStore.SignedDataVerifier.verify_and_decode_transaction(config, signed_transaction_info)
  """

  alias AppStore.JWSValidation
  alias AppStore.SignedDataVerifier.Config

  @doc """
  Verify and decode a `signedTransaction` obtained from the App Store Server API, an
  App Store Server Notification, or from a device.
  """
  @spec verify_and_decode_transaction(Config.t(), String.t()) ::
          {:ok, %JOSE.JWT{}} | {:error, atom}
  def verify_and_decode_transaction(%Config{} = config, signed_transaction_info) do
    with {:ok, jwt} <- verify_jwt(config, signed_transaction_info),
         :ok <- check_bundle_id(config, jwt.fields["bundleId"]),
         :ok <- check_environment(config, jwt.fields["environment"]) do
      {:ok, jwt}
    end
  end

  @doc """
  Verify and decode a `signedRenewalInfo` obtained from the App Store Server API, an
  App Store Server Notification, or from a device.
  """
  @spec verify_and_decode_renewal_info(Config.t(), String.t()) ::
          {:ok, %JOSE.JWT{}} | {:error, atom}
  def verify_and_decode_renewal_info(%Config{} = config, signed_renewal_info) do
    with {:ok, jwt} <- verify_jwt(config, signed_renewal_info),
         :ok <- check_environment(config, jwt.fields["environment"]) do
      {:ok, jwt}
    end
  end

  @doc """
  Verify and decode an App Store Server Notification `signedPayload`.
  """
  @spec verify_and_decode_notification(Config.t(), String.t()) ::
          {:ok, %JOSE.JWT{}} | {:error, atom}
  def verify_and_decode_notification(%Config{} = config, signed_payload) do
    with {:ok, jwt} <- verify_jwt(config, signed_payload) do
      {bundle_id, app_apple_id, environment} = notification_identity(jwt.fields)

      with :ok <- check_app_identifier(config, bundle_id, app_apple_id),
           :ok <- check_environment(config, environment) do
        {:ok, jwt}
      end
    end
  end

  @doc """
  Verify and decode a signed `AppTransaction`.
  """
  @spec verify_and_decode_app_transaction(Config.t(), String.t()) ::
          {:ok, %JOSE.JWT{}} | {:error, atom}
  def verify_and_decode_app_transaction(%Config{} = config, signed_app_transaction) do
    with {:ok, jwt} <- verify_jwt(config, signed_app_transaction),
         :ok <- check_app_identifier(config, jwt.fields["bundleId"], jwt.fields["appAppleId"]),
         :ok <- check_environment(config, jwt.fields["receiptType"]) do
      {:ok, jwt}
    end
  end

  @doc """
  Verify and decode a Retention Messaging API `signedPayload`.
  """
  @spec verify_and_decode_realtime_request(Config.t(), String.t()) ::
          {:ok, %JOSE.JWT{}} | {:error, atom}
  def verify_and_decode_realtime_request(%Config{} = config, signed_payload) do
    with {:ok, jwt} <- verify_jwt(config, signed_payload),
         :ok <- check_app_apple_id(config, jwt.fields["appAppleId"]),
         :ok <- check_environment(config, jwt.fields["environment"]) do
      {:ok, jwt}
    end
  end

  defp notification_identity(%{"data" => data}) when is_map(data) do
    {data["bundleId"], data["appAppleId"], data["environment"]}
  end

  defp notification_identity(%{"summary" => summary}) when is_map(summary) do
    {summary["bundleId"], summary["appAppleId"], summary["environment"]}
  end

  defp notification_identity(%{"externalPurchaseToken" => token}) when is_map(token) do
    environment =
      if is_binary(token["externalPurchaseId"]) and
           String.starts_with?(token["externalPurchaseId"], "SANDBOX") do
        "Sandbox"
      else
        "Production"
      end

    {token["bundleId"], token["appAppleId"], environment}
  end

  defp notification_identity(%{"appData" => app_data}) when is_map(app_data) do
    {app_data["bundleId"], app_data["appAppleId"], app_data["environment"]}
  end

  defp notification_identity(_fields), do: {nil, nil, nil}

  defp check_bundle_id(%Config{bundle_id: bundle_id}, bundle_id), do: :ok
  defp check_bundle_id(_config, _bundle_id), do: {:error, :invalid_app_identifier}

  defp check_app_apple_id(
         %Config{environment: "Production", app_apple_id: app_apple_id},
         app_apple_id
       ),
       do: :ok

  defp check_app_apple_id(%Config{environment: "Production"}, _app_apple_id),
    do: {:error, :invalid_app_identifier}

  defp check_app_apple_id(_config, _app_apple_id), do: :ok

  defp check_app_identifier(%Config{} = config, bundle_id, app_apple_id) do
    if config.bundle_id == bundle_id do
      check_app_apple_id(config, app_apple_id)
    else
      {:error, :invalid_app_identifier}
    end
  end

  defp check_environment(%Config{environment: environment}, environment), do: :ok
  defp check_environment(_config, _environment), do: {:error, :invalid_environment}

  # Xcode and LocalTesting payloads are not signed by the App Store; verification is skipped.
  # The caller-facing functions above still perform the environment check.
  defp verify_jwt(%Config{environment: environment}, jws)
       when environment in ["Xcode", "LocalTesting"] do
    {:ok, JOSE.JWT.peek(jws)}
  end

  defp verify_jwt(%Config{} = config, jws) do
    with {:ok, cert_chain} <- JWSValidation.get_binary_cert_chain(jws),
         :ok <- check_chain_length(cert_chain),
         {:ok, _pk_info} <- validate_against_any_root(cert_chain, config.root_certificates),
         {true, jwt, _jws} <- JOSE.JWT.verify(leaf_jwk(cert_chain), jws) do
      {:ok, jwt}
    else
      {false, _jwt, _jws} -> {:error, :verification_failure}
      {:error, reason} -> {:error, reason}
    end
  end

  defp check_chain_length([_leaf, _intermediate, _root]), do: :ok
  defp check_chain_length(_chain), do: {:error, :invalid_chain_length}

  defp validate_against_any_root(cert_chain, root_certificates) do
    Enum.find_value(root_certificates, {:error, :invalid_cert_chain}, fn root_certificate ->
      case JWSValidation.validate_certificate_chain(cert_chain, root_certificate) do
        {:ok, _pk_info} = ok -> ok
        {:error, _reason} -> nil
      end
    end)
  end

  defp leaf_jwk([leaf_cert | _rest]) do
    {:OTPCertificate,
     {:OTPTBSCertificate, _, _, _, _, _, _,
      {:OTPSubjectPublicKeyInfo, {:PublicKeyAlgorithm, _, {:namedCurve, _curve} = curve},
       {:ECPoint, _ec_point} = ec_point}, _, _, _}, _, _} =
      :public_key.pkix_decode_cert(leaf_cert, :otp)

    JOSE.JWK.from_key({ec_point, curve})
  end
end
