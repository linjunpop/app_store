defmodule AppStore.API.MessagingImageTest do
  use AppStore.TestCase, async: false

  alias AppStore.API.MessagingImage

  describe "upload_image/5" do
    test "uploads a PNG image", %{bypass: bypass, app_store: app_store} do
      Passby.expect_once(bypass, "PUT", "/inApps/v1/messaging/image/img-id", fn conn ->
        assert conn.query_string === "imageSize=LARGE"
        assert {"content-type", "image/png"} in conn.req_headers

        Passby.Conn.resp(conn, 200, "")
      end)

      {:ok, %AppStore.API.Response{status: status}} =
        MessagingImage.upload_image(app_store.api_config, "token", "img-id", <<1, 2, 3>>, "LARGE")

      assert status === 200
    end
  end

  describe "delete_image/3" do
    test "deletes an image", %{bypass: bypass, app_store: app_store} do
      Passby.expect_once(bypass, "DELETE", "/inApps/v1/messaging/image/img-id", fn conn ->
        Passby.Conn.resp(conn, 200, "")
      end)

      {:ok, %AppStore.API.Response{status: status}} =
        MessagingImage.delete_image(app_store.api_config, "token", "img-id")

      assert status === 200
    end
  end

  describe "get_image_list/2" do
    test "gets the image list", %{bypass: bypass, app_store: app_store} do
      expected_body = %{images: []} |> Jason.encode!()

      Passby.expect_once(bypass, "GET", "/inApps/v1/messaging/image/list", fn conn ->
        Passby.Conn.resp(conn, 200, expected_body)
      end)

      {:ok, %AppStore.API.Response{body: body, status: status}} =
        MessagingImage.get_image_list(app_store.api_config, "token")

      assert status === 200
      assert body === expected_body
    end
  end
end
