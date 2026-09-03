defmodule AppStore.ServerNotifications do
  @moduledoc """
  Receives and verifies App Store Server Notifications V2 request bodies.

  This module is framework-neutral. Pass the raw HTTP request body to
  `decode/3`, then return a `2xx` response after handling the notification.
  Return a `4xx` or `5xx` response when processing fails and Apple should retry.

  See the [Server Notifications](server-notifications.html) guide for
  configuration, acknowledgement policy, and idempotent processing.
  """

  alias AppStore.JSON
  alias AppStore.SignedDataVerifier
  alias AppStore.SignedDataVerifier.Config

  defstruct [:envelope, :notification, :transaction_info, :renewal_info]

  @type t :: %__MODULE__{
          envelope: map(),
          notification: %JOSE.JWT{},
          transaction_info: %JOSE.JWT{} | nil,
          renewal_info: %JOSE.JWT{} | nil
        }

  @type error ::
          :invalid_body
          | :invalid_json
          | :missing_signed_payload
          | :invalid_signed_payload
          | {:invalid_nested_signed_data, String.t()}
          | atom()

  @doc """
  Decode and verify an App Store Server Notifications V2 request body.

  Nested `signedTransactionInfo` and `signedRenewalInfo` values are verified
  when present. If either value is present but cannot be verified, decoding
  fails so callers do not accidentally process unverified purchase state.
  """
  @spec decode(Config.t(), String.t(), module()) :: {:ok, t()} | {:error, error()}
  def decode(config, body, json_coder \\ AppStore.JSON.DefaultCoder)

  def decode(%Config{} = config, body, json_coder) when is_binary(body) do
    with {:ok, envelope} <- decode_body(json_coder, body),
         {:ok, signed_payload} <- signed_payload(envelope),
         {:ok, notification} <- verify_notification(config, signed_payload),
         {:ok, transaction_info} <- verify_transaction(config, notification),
         {:ok, renewal_info} <- verify_renewal_info(config, notification) do
      {:ok,
       %__MODULE__{
         envelope: envelope,
         notification: notification,
         transaction_info: transaction_info,
         renewal_info: renewal_info
       }}
    end
  end

  def decode(%Config{}, _body, _json_coder), do: {:error, :invalid_body}

  @doc "Returns whether an HTTP status acknowledges a notification post."
  @spec successful_status?(non_neg_integer()) :: boolean()
  def successful_status?(status), do: status in 200..206

  @doc "Returns whether an HTTP status asks Apple to retry a notification post."
  @spec retryable_status?(non_neg_integer()) :: boolean()
  def retryable_status?(status), do: status in 400..599

  defp decode_body(json_coder, body) do
    decoded = JSON.decode!(json_coder, body)

    if is_map(decoded) do
      {:ok, decoded}
    else
      {:error, :invalid_json}
    end
  rescue
    _error -> {:error, :invalid_json}
  end

  defp signed_payload(%{"signedPayload" => signed_payload}) when is_binary(signed_payload) do
    {:ok, signed_payload}
  end

  defp signed_payload(%{"signedPayload" => _signed_payload}),
    do: {:error, :invalid_signed_payload}

  defp signed_payload(_envelope), do: {:error, :missing_signed_payload}

  defp verify_notification(config, signed_payload) do
    case SignedDataVerifier.verify_and_decode_notification(config, signed_payload) do
      {:ok, notification} -> {:ok, notification}
      {:error, _reason} -> {:error, :invalid_signed_payload}
    end
  rescue
    _error -> {:error, :invalid_signed_payload}
  end

  defp verify_transaction(config, %JOSE.JWT{fields: %{"data" => data}})
       when is_map(data) do
    verify_nested(
      config,
      data,
      "signedTransactionInfo",
      &SignedDataVerifier.verify_and_decode_transaction/2
    )
  end

  defp verify_transaction(_config, _notification), do: {:ok, nil}

  defp verify_renewal_info(config, %JOSE.JWT{fields: %{"data" => data}})
       when is_map(data) do
    verify_nested(
      config,
      data,
      "signedRenewalInfo",
      &SignedDataVerifier.verify_and_decode_renewal_info/2
    )
  end

  defp verify_renewal_info(_config, _notification), do: {:ok, nil}

  defp verify_nested(config, data, key, verifier) do
    case Map.get(data, key) do
      nil ->
        {:ok, nil}

      signed_data when is_binary(signed_data) ->
        case verifier.(config, signed_data) do
          {:ok, jwt} -> {:ok, jwt}
          {:error, _reason} -> {:error, {:invalid_nested_signed_data, key}}
        end

      _signed_data ->
        {:error, {:invalid_nested_signed_data, key}}
    end
  rescue
    _error -> {:error, {:invalid_nested_signed_data, key}}
  end
end
