defmodule AppStore.ReceiptUtility do
  @moduledoc """
  Extracts a transaction ID from legacy App Receipts and transaction receipts.

  *No validation* is performed on the receipt; any data returned should only be
  used to call the App Store Server API.
  """

  alias AppStore.ReceiptUtility.ASN1

  @in_app_type_id 17
  @transaction_identifier_type_id 1703
  @original_transaction_identifier_type_id 1705

  @purchase_info_regex ~r/"purchase-info"\s+=\s+"([a-zA-Z0-9+\/=]+)";/
  @transaction_id_regex ~r/"transaction-id"\s+=\s+"([a-zA-Z0-9+\/=]+)";/

  @doc """
  Extract a transaction id from an encoded App Receipt. Raises if the receipt does not
  match the expected format.

  Returns the first transaction id from the array of in-app purchases, or `nil` if the
  receipt contains none.
  """
  @spec extract_transaction_id_from_app_receipt(String.t()) :: String.t() | nil
  def extract_transaction_id_from_app_receipt(app_receipt) do
    app_receipt
    |> Base.decode64!()
    # ContentInfo -> [0] SignedData -> SignedData -> contentInfo -> [0] -> OCTET STRING
    |> ASN1.navigate([1, 0, 2, 1, 0])
    |> ASN1.unwrap_nested_octet_string()
    |> find_transaction_id()
  end

  @doc """
  Extract a transaction id from an encoded legacy transaction receipt. Raises if the
  receipt does not match the expected format.

  Returns `nil` if no transaction id is found in the receipt.
  """
  @spec extract_transaction_id_from_transaction_receipt(String.t()) :: String.t() | nil
  def extract_transaction_id_from_transaction_receipt(transaction_receipt) do
    with {:ok, top_level} <- Base.decode64(transaction_receipt),
         [_, purchase_info_b64] <- Regex.run(@purchase_info_regex, top_level),
         {:ok, purchase_info} <- Base.decode64(purchase_info_b64),
         [_, transaction_id] <- Regex.run(@transaction_id_regex, purchase_info) do
      transaction_id
    else
      _ -> nil
    end
  end

  defp find_transaction_id(nil), do: nil

  defp find_transaction_id(receipt_attributes) do
    receipt_attributes
    |> ASN1.children()
    |> Enum.find_value(fn attribute ->
      if ASN1.attribute_type(attribute) == @in_app_type_id do
        find_transaction_id_in_app(attribute)
      end
    end)
  end

  defp find_transaction_id_in_app(in_app_attribute) do
    in_app_attribute
    |> ASN1.child(2)
    |> ASN1.content()
    |> ASN1.children()
    |> Enum.find_value(fn item ->
      type = ASN1.attribute_type(item)

      if type in [@transaction_identifier_type_id, @original_transaction_identifier_type_id] do
        item
        |> ASN1.child(2)
        |> ASN1.content()
        |> ASN1.content()
      end
    end)
  end
end
