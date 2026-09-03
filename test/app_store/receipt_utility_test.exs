defmodule AppStore.ReceiptUtilityTest do
  use ExUnit.Case

  alias AppStore.ReceiptUtility

  @fixtures_path Path.join([__DIR__, "..", "support", "fixtures", "receipts"])

  defp read_fixture(name) do
    @fixtures_path
    |> Path.join(name)
    |> File.read!()
    |> String.trim()
  end

  describe "extract_transaction_id_from_app_receipt/1" do
    test "returns nil for an xcode receipt without a transaction" do
      receipt = read_fixture("xcode-app-receipt-empty")

      assert ReceiptUtility.extract_transaction_id_from_app_receipt(receipt) == nil
    end

    test "extracts a transaction id from an xcode receipt with a transaction" do
      receipt = read_fixture("xcode-app-receipt-with-transaction")

      assert ReceiptUtility.extract_transaction_id_from_app_receipt(receipt) == "0"
    end
  end

  describe "extract_transaction_id_from_transaction_receipt/1" do
    test "extracts a transaction id from a legacy transaction receipt" do
      receipt = read_fixture("legacy-transaction")

      assert ReceiptUtility.extract_transaction_id_from_transaction_receipt(receipt) ==
               "33993399"
    end
  end
end
