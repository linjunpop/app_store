defmodule AppStore.JWSValidation do
  @moduledoc """
  A module to validate the JWS from Apple.
  """

  # Apple Root CA G3 public certificate available at https://www.apple.com/certificateauthority/
  @apple_root_cert File.read!(Path.join(File.cwd!(), "/priv/certs/AppleRootCA-G3.cer"))

  @doc """
  Validate the signed payload from Apple.

  Official documentation: [JWS Transaction
  ](https://developer.apple.com/documentation/appstoreserverapi/jwstransaction)

  ## Examples
      iex> AppStore.JWSValidation.validate("
        eyJhbGciOiJFUzI1NiIsImtpZCI6IjJYOVI0SFhGMzQiLCJ0eXAiOiJKV1QifQ.eyJhdWQiOiJhcHBzdG9yZWNvbm5lY3QtdjEiLCJiaWQiOiJjb20uZXhhbXBsZS50ZXN0YnVuZGxlaWQyMDIxIiwiZXhwIjoxNjI5NTA2MjQwLCJpYXQiOjE2Mjk1MDI3MDAsImlzcyI6IjU3MjQ2NTQyLTk2ZmUtMWE2My1lMDUzLTA4MjRkMDExMDcyYSIsIm5vbmNlIjoiMnFlaWc0a2wxOTQ0aHFhbmVzMDAwMGMxIn0.gYa_A7J6a6UAyBTAohf4gj28jT0k-OX1CW8cwsVGb4EewEm3owdsv6iWvzt7SutCndCBg5hPfNFWuZ0Au20HxA"
      )
      {:ok,
       %JOSE.JWT{
         fields: %{
           "bundleId" => "com.example",
           "environment" => "Sandbox",
           "signedDate" => 1_672_956_154_000
         }
       }}

      iex> AppStore.JWSValidation.validate(["signed_payload1", "signed_payload2"]))
      [
        {:ok, %JOSE.JWT{fields: %{"bundleId" => "com.example", "environment" => "Sandbox", "signedDate" => 1_672_956_154_000}}},
        {:ok, %JOSE.JWT{fields: %{"bundleId" => "com.example2", "environment" => "Sandbox", "signedDate" => 1_672_956_154_000}}}
      ]
  """
  @spec validate(String.t() | list()) :: {:error, atom} | {:ok, %JOSE.JWT{}}
  def validate(signed_payload) when is_binary(signed_payload) do
    with {:ok, [leaf_cert | _] = cert_chain} <- get_binary_cert_chain(signed_payload),
         {:ok, _pk_info} <- __MODULE__.validate_certificate_chain(cert_chain),
         {true, jwt, _jws} <- JOSE.JWT.verify(get_jwk(leaf_cert), signed_payload) do
      {:ok, jwt}
    else
      {_valid_signature? = false, _jwt, _jws} -> {:error, :invalid_signature}
      {:error, reason} -> {:error, reason}
    end
  end

  def validate(signed_payloads) when is_list(signed_payloads) do
    Enum.map(signed_payloads, &validate/1)
  end

  def validate(_), do: {:error, :invalid_jws}

  def get_binary_cert_chain(signed_payload) do
    with header <- JOSE.JWS.peek_protected(signed_payload),
         {:ok, decoded_header} <- Jason.decode(header),
         [_ | _] = base64_cert_chain <- Map.get(decoded_header, "x5c") do
      {:ok, Enum.map(base64_cert_chain, &Base.decode64!/1)}
    else
      _ -> {:error, :invalid_jws}
    end
  end

  # We allow sending an ext_apple_root_cert (external) to be able to test this function
  def validate_certificate_chain(cert_chain, ext_apple_root_cert \\ nil)

  def validate_certificate_chain([raw_leaf, raw_intermediate, _raw_root], ext_apple_root_cert) do
    apple_root_cert = ext_apple_root_cert || @apple_root_cert

    case :public_key.pkix_path_validation(apple_root_cert, [raw_intermediate, raw_leaf], []) do
      {:ok, pk_info} -> {:ok, pk_info}
      _ -> {:error, :invalid_cert_chain}
    end
  end

  def validate_certificate_chain(_, _), do: {:error, :invalid_cert_chain}

  defp get_jwk(leaf_cert) do
    leaf_cert
    |> X509.Certificate.from_der!()
    |> X509.Certificate.public_key()
    |> JOSE.JWK.from_key()
  end
end
