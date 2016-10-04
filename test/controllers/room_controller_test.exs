defmodule Chat.RoomControllerTest do
  use Chat.ConnCase

  alias Chat.Room
  @valid_attrs %{uuid: "some content"}
  @invalid_attrs %{}

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, room_path(conn, :create), %{}
    assert redirected_to(conn) == room_path(conn, :show)
  end

  test "shows chosen resource", %{conn: conn} do
    conn = get conn, room_path(conn, :show, "ROOM_ID_HOGE")
    assert html_response(conn, 200) =~ "Room"
  end
end
