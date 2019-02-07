defmodule Overseer.ImageUpload do
  import Mogrify

  require Logger

  alias Overseer.{Utils, WockyApi}

  @image_file "data/image.jpg"

  def run() do
    Logger.debug "Authenticating..."
    Utils.authenticate()

    image = File.read!(@image_file)

    full_task = Task.async(&make_full/0)
    thumb_task = Task.async(&make_thumb/0)

    # Upload
    Logger.debug "Getting upload URL..."
    {:ok, data} = WockyApi.get(:upload, ["test-file.jpg", byte_size(image), "image/jpeg"])
    result = data["result"]
    method = result["method"] |> String.downcase() |> String.to_atom()

    Logger.debug "Uploading..."
    {:ok, 200, _, _} = :hackney.request(method, result["uploadUrl"], headers(result["headers"]), image, connect_timeout: 120000, recv_timeout: 120000)

    # Download
    Logger.debug "Getting download URLs..."
    {:ok, data} = WockyApi.get(:media_urls, [result["referenceUrl"], 120_000])

    Logger.debug "Downloading thumbnail"
    {:ok, 200, _, ref} = :hackney.request(:get, data["thumbnailUrl"])
    {:ok, thumb} = :hackney.body(ref)
    File.write!("data/thumb_down.jpg", thumb)

    Logger.debug "Downloading full size"
    {:ok, 200, _, ref} = :hackney.request(:get, data["fullUrl"])
    {:ok, full} = :hackney.body(ref)
    File.write!("data/full_down.jpg", full)

    Task.await(full_task)
    Task.await(thumb_task)
  end

  defp headers(headerList),
    do: Enum.map(headerList, fn %{"name" => name, "value" => val} -> {name, val} end)

  defp make_full() do
    @image_file
    |> open()
    |> custom("strip")
    |> resize("1920x1920^")
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
end
