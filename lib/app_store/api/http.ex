defmodule AppStore.API.HTTP do
  @moduledoc false

  alias AppStore.API.{Config, Error, Response}
  alias AppStore.HTTPClient

  def get(%Config{} = api_config, token, path) do
    perform_request(api_config, token, :get, path, nil, [])
  end

  def put(%Config{} = api_config, token, path, body, opts \\ []) do
    perform_request(api_config, token, :put, path, body, opts)
  end

  def post(%Config{} = api_config, token, path, body \\ nil, opts \\ []) do
    perform_request(api_config, token, :post, path, body, opts)
  end

  def delete(%Config{} = api_config, token, path) do
    perform_request(api_config, token, :delete, path, nil, [])
  end

  @doc """
  Build a query string from a keyword list/map of params, dropping `nil` values and
  repeating the key for each item of a list value (Apple's convention for multi-value filters).
  """
  @spec build_query(Enum.t()) :: String.t()
  def build_query(params) do
    params
    |> Enum.reject(fn {_key, value} -> is_nil(value) end)
    |> Enum.flat_map(fn
      {key, values} when is_list(values) -> Enum.map(values, &{key, &1})
      {key, value} -> [{key, value}]
    end)
    |> URI.encode_query()
  end

  defp perform_request(
         %Config{http_client: http_client, json_coder: json_coder, server_url: server_url},
         token,
         method,
         path,
         body,
         opts
       ) do
    content_type = Keyword.get(opts, :content_type, "application/json")

    uri = build_uri(server_url, path)
    body = format_body(json_coder, body, content_type)
    headers = build_headers(token, content_type)

    case HTTPClient.perform_request(http_client, method, uri, body, headers) do
      {:ok, response} ->
        {:ok, struct!(Response, response)}

      {:error, error} ->
        {:error, struct!(Error, error)}
    end
  end

  defp build_headers(token, content_type) do
    [
      {"authorization", "Bearer #{token}"},
      {"accept", "application/json"},
      {"content-type", content_type},
      {"user-agent", "Elixir:AppStore/#{AppStore.version()}"}
    ]
  end

  defp build_uri(_server_url, path) when is_struct(path, URI) do
    path
  end

  defp build_uri(server_url, path) do
    url = Path.join(server_url, path)

    URI.parse(url)
  end

  # raw content types (e.g. images) are passed through untouched, never JSON-encoded
  defp format_body(_, nil, _content_type), do: ""

  defp format_body(_, str, _content_type) when is_binary(str) do
    str
  end

  defp format_body(json_coder, params, _content_type) when is_map(params) do
    AppStore.JSON.encode!(json_coder, params)
  end
end
