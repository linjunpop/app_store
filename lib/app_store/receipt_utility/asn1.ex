defmodule AppStore.ReceiptUtility.ASN1 do
  @moduledoc false

  # A minimal DER/BER TLV (tag-length-value) reader, just capable enough to walk the
  # PKCS#7 structure of a legacy App Receipt. Supports both definite and indefinite
  # length encoding (the latter used by Xcode-built receipts), terminated by an
  # end-of-contents marker (`00 00`).

  @type tlv :: binary()

  @doc """
  Descend into nested TLVs by child index, mirroring how a legacy App Receipt's
  ASN.1 structure is navigated: `path` is a list of 0-based child indices, applied
  one nesting level at a time. Returns the content (`V`) of the TLV found at the
  end of `path`, or `nil` if any step is out of range.
  """
  @spec navigate(tlv, [non_neg_integer()]) :: binary() | nil
  def navigate(tlv, path)

  def navigate(nil, _path), do: nil
  def navigate(tlv, []), do: content(tlv)

  def navigate(tlv, [index | rest]) do
    tlv
    |> child(index)
    |> navigate(rest)
  end

  @doc "Get the raw TLV bytes of the `index`-th child of a TLV, or `nil` if out of range."
  @spec child(tlv, non_neg_integer()) :: tlv | nil
  def child(nil, _index), do: nil

  def child(tlv, index) do
    tlv
    |> children()
    |> Enum.at(index)
  end

  @doc "Get the content (`V`) bytes of a single TLV."
  @spec content(tlv) :: binary()
  def content(tlv) do
    {_tag, content, _rest} = parse(tlv)
    content
  end

  @doc "Split a binary made of consecutive sibling TLVs into their raw bytes."
  @spec siblings(binary()) :: [tlv]
  def siblings(<<>>), do: []

  def siblings(binary) do
    {consumed, rest} = split_one(binary)
    [consumed | siblings(rest)]
  end

  @doc "Get the raw bytes of a TLV's immediate children (its content, split into siblings)."
  @spec children(tlv) :: [tlv]
  def children(tlv), do: tlv |> content() |> siblings()

  @doc "Decode a receipt attribute's `type` field (its first child, an ASN.1 INTEGER)."
  @spec attribute_type(tlv) :: non_neg_integer()
  def attribute_type(tlv) do
    tlv
    |> child(0)
    |> content()
    |> :binary.decode_unsigned()
  end

  # Xcode-built (simulator) receipts double-wrap the receipt payload in an extra
  # OCTET STRING; unwrap it once more when detected.
  @doc false
  @spec unwrap_nested_octet_string(binary() | nil) :: binary() | nil
  def unwrap_nested_octet_string(nil), do: nil
  def unwrap_nested_octet_string(<<0x04, _rest::binary>> = content), do: content(content)
  def unwrap_nested_octet_string(content), do: content

  # Parses one TLV from the start of `binary`, returning {tag, content, rest}.
  defp parse(<<tag, rest::binary>>) do
    case read_length(rest) do
      {:definite, length, rest} ->
        <<content::binary-size(^length), rest::binary>> = rest
        {tag, content, rest}

      {:indefinite, rest} ->
        {content, rest} = read_until_end_of_contents(rest)
        {tag, content, rest}
    end
  end

  defp read_length(<<0x80, rest::binary>>), do: {:indefinite, rest}
  defp read_length(<<length, rest::binary>>) when length < 0x80, do: {:definite, length, rest}

  defp read_length(<<length_of_length, rest::binary>>) do
    n = length_of_length - 0x80
    <<length_bytes::binary-size(^n), rest::binary>> = rest
    {:definite, :binary.decode_unsigned(length_bytes), rest}
  end

  defp read_until_end_of_contents(<<0x00, 0x00, rest::binary>>), do: {<<>>, rest}

  defp read_until_end_of_contents(binary) do
    {consumed, rest} = split_one(binary)
    {more, rest} = read_until_end_of_contents(rest)
    {consumed <> more, rest}
  end

  # Parses one TLV and returns its full raw bytes (tag + length + content) alongside
  # whatever bytes remain, without decoding the content further.
  defp split_one(binary) do
    {_tag, _content, rest} = parse(binary)
    consumed_size = byte_size(binary) - byte_size(rest)
    <<consumed::binary-size(^consumed_size), _::binary>> = binary
    {consumed, rest}
  end
end
