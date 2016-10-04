defmodule Chat.RoomController do
  require Logger
  use Chat.Web, :controller

  alias Chat.Room

  def create(conn, _params) do
    uuid = Ecto.UUID.generate
    conn
    |> put_flash(:info, "Room created successfully.")
    |> redirect(to: room_path(conn, :show, uuid))
  end

  def show(conn, %{"id" => uuid}) do
    Logger.debug("uuid: #{inspect uuid}")
    render(conn, "show.html", uuid: uuid)
  end
end
