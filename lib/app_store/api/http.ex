defmodule AppStore.API.HTTP do
  @moduledoc false

  alias AppStore.API.{Config, Error, Response}
  alias AppStore.HTTPClient

  def get(%Config{} = api_config, token, path) do
    perform_request(api_config, token, :get, path, nil)
  end

  def put(%Config{} = api_config, token, path, body) do
    perform_request(api_config, token, :put, path, body)
  end

  defp perform_request(
         %Config{http_client: http_client, json_coder: json_coder, server_url: server_url},
         token,
         method,
         path,
         body
       ) do
    uri = build_uri(server_url, path)
    body = format_body(json_coder, body)
    headers = build_headers(token)

    case HTTPClient.perform_request(http_client, method, uri, body, headers) do
      {:ok, response} ->
        {:ok, struct!(Response, response)}

      {:error, error} ->
        {:error, struct!(Error, error)}
    end
  end

  defp build_headers(token) do
    [
      {"authorization", "Bearer #{token}"},
      {"accept", "application/json"},
      {"content-type", "application/json"},
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

  defp format_body(_, nil), do: ""

  defp format_body(_, str) when is_binary(str) do
    str
  end

  defp format_body(json_coder, params) when is_map(params) do
    AppStore.JSON.encode!(json_coder, params)
  end
end
