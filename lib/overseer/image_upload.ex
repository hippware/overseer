defmodule Overseer.ImageUpload do
  alias Overseer.{Utils, WockyApi}

  def run() do
    jwt = Utils.jwt()

    WockyApi.get(:auth, jwt)
  end
end
