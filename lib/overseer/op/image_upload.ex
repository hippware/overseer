defmodule Overseer.Op.ImageUpload do
  import Mogrify

  require Logger

  alias Overseer.{Utils, WockyApi}

  @image_file "data/original.jpg"

  @mindim 400
  @maxdim 3200

  def run() do
    Logger.info("Authenticating...")
    Utils.authenticate()

    image = get_test_image()

    Logger.info("Creating comparrison images...")
    make_full()
    make_thumb()

    # Upload
    Logger.info("Getting upload URL...")

    {:ok, data} =
      WockyApi.get(:upload, ["test-file.jpg", byte_size(image), "image/jpeg"])

    result = data["result"]
    method = result["method"] |> String.downcase() |> String.to_atom()

    Logger.info("Uploading...")

    %{status_code: 200} =
      HTTPoison.request!(
        method,
        result["uploadUrl"],
        image,
        headers(result["headers"]),
        connect_timeout: 120_000,
        recv_timeout: 120_000
      )

    # Download
    Logger.info("Getting download URLs...")
    {:ok, data} = WockyApi.get(:media_urls, [result["referenceUrl"], 120_000])

    Logger.info("Downloading thumbnail")
    download(data["thumbnailUrl"], "data/thumb_down.jpg")

    Logger.info("Downloading full image")
    download(data["fullUrl"], "data/full_down.jpg")

    # Compare
    Logger.info("Running comparrison")
    {output, 0} = System.cmd("findimagedupes", ["--threshold=5", "data"])
    Logger.info("Comparrison output: #{output}")

    expected = ["full.jpg", "full_down.jpg", "thumb.jpg", "thumb_down.jpg"]
    Enum.each(expected, fn e -> true = String.contains?(output, e) end)

    Logger.info("Test complete")
  end

  defp headers(headerList),
    do:
      Enum.map(headerList, fn %{"name" => name, "value" => val} ->
        {name, val}
      end)

  defp get_test_image() do
    x = randdim()
    y = randdim()

    Logger.info("Downloading image #{x}x#{y}")

    result =
      HTTPoison.get("https://picsum.photos/#{x}/#{y}", [],
        follow_redirect: true
      )

    body = case result do
      {:ok, %{body: body, status_code: 200}} ->
        body
      r ->
        Logger.warn(
          """
          Could not download test image; using fallback. Result: #{inspect r}
          """)
        fallback_file()
        |> File.read!()
    end

    File.write!(@image_file, body)
    body
  end

  defp download(url, filename) do
    %{body: body, status_code: 200} = HTTPoison.get!(url)
    File.write!(filename, body)
  end

  defp randdim(), do: :rand.uniform(@maxdim - @mindim) + @mindim

  defp make_full() do
    @image_file
    |> open()
    |> custom("strip")
    |> resize("1920x1920>")
    |> save(path: "data/full.jpg")
  end

  defp make_thumb() do
    @image_file
    |> open()
    |> custom("strip")
    |> custom("thumbnail", "360x360^")
    |> gravity("center")
    |> extent("360x360")
    |> save(path: "data/thumb.jpg")
  end

  defp fallback_file do
    :overseer
    |> :code.priv_dir()
    |> to_string()
    |> Path.join("fallback.jpg")
  end
end
