defmodule Overseer.Query.Media do
  def upload do
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
    """
  end

  def media_urls do
    """
    query ($trosUrl: String!, $timeout: Int!) {
      mediaUrls (trosUrl: $trosUrl, timeout: $timeout) {
        fullUrl
        thumbnailUrl
      }
    }
    """
  end
end
