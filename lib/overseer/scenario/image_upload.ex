defmodule Overseer.Scenario.ImageUpload do
  @moduledoc "Test scenario for image uploads"

  import Mogrify

  use Overseer.Chaperon.Scenario

  alias Overseer.Query.Media
  alias Overseer.Scenario.Utils

  @image_file "data/original.jpg"

  @mindim 400
  @maxdim 3200

  def init(session), do: {:ok, session}

  def run(session!) do
    [x, y] = session!.config.args

    session! = Utils.authenticate(session!)

    image = get_test_image(x, y)

    make_full()
    make_thumb()

    # Upload
    session! =
      session!
      |> log_info("Getting upload URL")
      |> aws_send(Media.upload("test-file.jpg", byte_size(image), "image/jpeg"))
      |> aws_recv()

    result = get_last(session!).payload.response.data.mediaUpload.result
    method = result.method |> String.downcase() |> String.to_atom()

    session! = log_info(session!, "Uploading...")

    %{status_code: 200} =
      HTTPoison.request!(
        method,
        result.uploadUrl,
        image,
        headers(result.headers),
        connect_timeout: 120_000,
        recv_timeout: 120_000
      )

    # Download
    session! =
      session!
      |> log_info("Getting download URLs...")
      |> aws_send(Media.media_urls(result.referenceUrl, 120_000))
      |> aws_recv()

    urls = get_last(session!).payload.response.data.mediaUrls

    session! = log_info(session!, "Downloading thumbnail")
    download(urls.thumbnailUrl, "data/thumb_down.jpg")

    session! = log_info(session!, "Downloading full image")
    download(urls.fullUrl, "data/full_down.jpg")

    # Compare
    session! = log_info(session!, "Running comparrison")
    {output, 0} = System.cmd("findimagedupes", ["--threshold=5", "data"])
    session! = log_info(session!, "Comparrison output: #{output}")

    expected = ["full.jpg", "full_down.jpg", "thumb.jpg", "thumb_down.jpg"]
    Enum.each(expected, fn e -> true = String.contains?(output, e) end)

    session!
    |> log_info("Test complete")
    |> aws_close()
  end

  defp headers(headerList),
    do:
      Enum.map(headerList, fn %{name: name, value: val} ->
        {name, val}
      end)

  defp get_test_image(x, y) do
    x = x || randdim()
    y = y || randdim()

    Logger.info("Downloading image #{x}x#{y}")

    result =
      HTTPoison.get("https://picsum.photos/#{x}/#{y}", [], follow_redirect: true)

    body =
      case result do
        {:ok, %{body: body, status_code: 200}} ->
          body

        r ->
          Logger.warn("""
          Could not download test image; using fallback. Result: #{inspect(r)}
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

  defp randdim, do: :rand.uniform(@maxdim - @mindim) + @mindim

  defp make_full do
    @image_file
    |> open()
    |> custom("strip")
    |> resize("1920x1920>")
    |> save(path: "data/full.jpg")
  end

  defp make_thumb do
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
