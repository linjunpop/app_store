defmodule AppStore.API.MessagingImage do
  @moduledoc """
  The module for managing Advanced Commerce retention messaging images
  """

  alias AppStore.API.{Config, Error, Response, HTTP}

  @type image_identifier :: String.t()
  @type image_size :: String.t() | nil

  @path_prefix "/inApps/v1/messaging/image"

  @doc """
  Upload a PNG image to use in a retention messaging message.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec upload_image(Config.t(), String.t(), image_identifier, binary, image_size) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def upload_image(%Config{} = api_config, token, image_identifier, image, image_size \\ nil)
      when is_binary(image) do
    query = HTTP.build_query(imageSize: image_size)

    path = "#{@path_prefix}/#{image_identifier}"
    path = if query == "", do: path, else: "#{path}?#{query}"

    HTTP.put(api_config, token, path, image, content_type: "image/png")
  end

  @doc """
  Delete a previously uploaded retention messaging image.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec delete_image(Config.t(), String.t(), image_identifier) ::
          {:error, Error.t()} | {:ok, Response.t()}
  def delete_image(%Config{} = api_config, token, image_identifier) do
    HTTP.delete(api_config, token, "#{@path_prefix}/#{image_identifier}")
  end

  @doc """
  Get the list of retention messaging images you uploaded.

  Official documentation: https://developer.apple.com/documentation/appstoreserverapi
  """
  @spec get_image_list(Config.t(), String.t()) :: {:error, Error.t()} | {:ok, Response.t()}
  def get_image_list(%Config{} = api_config, token) do
    HTTP.get(api_config, token, "#{@path_prefix}/list")
  end
end
