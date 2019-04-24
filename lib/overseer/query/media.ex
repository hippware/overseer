defmodule Overseer.Query.Media do
  def upload(filename, size, type, access \\ "all") do
    {
      """
      mutation ($filename: String!, $size: Int!,
                $mimeType: String!, $access: String!) {
        mediaUpload (input: {filename: $filename, size: $size,
                     mimeType: $mimeType, access: $access}) {
          successful
          result {
            id
            uploadUrl
            method
            headers {
              name
              value
            }
            referenceUrl
          }
        }
      }
      """,
      %{filename: filename, size: size, mimeType: type, access: access}
    }
  end

  def media_urls(url, timeout) do
    {
      """
      query ($trosUrl: String!, $timeout: Int!) {
        mediaUrls (trosUrl: $trosUrl, timeout: $timeout) {
          fullUrl
          thumbnailUrl
        }
      }
      """,
      %{trosUrl: url, timeout: timeout}
    }
  end
end
