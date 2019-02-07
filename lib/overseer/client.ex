defmodule Overseer.Client do
  alias Overseer.Query

  use CommonGraphQLClient.Client,
    otp_app: :overseer,
    mod: Overseer.WockyApi

  defp handle(:get, :auth, token) do
    do_post(
      :authenticate,
      nil,
      Query.Auth.auth(),
      %{token: token}
    )
  end

  defp handle(:get, :upload, [filename, size, mimeType]) do
    do_post(
      :mediaUpload,
      nil,
      Query.Media.upload(),
      %{filename: filename, size: size, mimeType: mimeType, access: "all"}
    )
  end

  defp handle(:get, :media_urls, [trosUrl, timeout]) do
    do_post(
      :mediaUrls,
      nil,
      Query.Media.media_urls(),
      %{trosUrl: trosUrl, timeout: timeout},
      timeout: timeout
    )
  end
end
