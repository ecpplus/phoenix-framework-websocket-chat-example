defmodule Chat.RoomChannel do
  require Logger
  require IEx

  use Chat.Web, :channel
  alias Phoenix.Socket.Broadcast


  def join("room:" <> room_uuid, payload, socket) do
    Logger.debug("hoge: #{inspect payload}, #{inspect socket}")
    if authorized?(payload) do
      socket = assign(socket, :user_name, payload["name"])
      send(self, :after_join)
      # :ok = ChannelWatcher.monitor(:rooms, self(), {__MODULE__, :leave, [socket, room_uuid, payload["name"]]})
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def terminate(msg, socket) do
    broadcast! socket, "new_msg", %{user_name: "System", body: "#{socket.assigns[:user_name]} left this room.", timestamp: :os.system_time(:milli_seconds)}
    broadcast! socket, "end_editing", %{user_name: socket.assigns[:user_name], timestamp: :os.system_time(:milli_seconds)}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    # Logger.debug("[in]new_msg: #{body}, #{inspect socket}")
    broadcast! socket, "new_msg", %{user_name: socket.assigns[:user_name], body: body, timestamp: :os.system_time(:milli_seconds)}
    broadcast! socket, "end_editing", %{user_name: socket.assigns[:user_name], timestamp: :os.system_time(:milli_seconds)}
    {:noreply, socket}
  end

  def handle_in("editing", _, socket) do
    # Logger.debug("[in]editing: #{inspect socket}")
    broadcast! socket, "editing", %{user_name: socket.assigns[:user_name], timestamp: :os.system_time(:milli_seconds)}
    {:noreply, socket}
  end

  def handle_in("end_editing", _, socket) do
    # Logger.debug("[in]end_editing: #{inspect socket}")
    broadcast! socket, "end_editing", %{user_name: socket.assigns[:user_name], timestamp: :os.system_time(:milli_seconds)}
    {:noreply, socket}
  end

  def handle_out("new_msg", payload, socket) do
    Logger.debug("[out]new_msg: #{inspect payload}")
    # push socket, "new_msg", payload
    push socket, "new_msg", %{body: 'dummy'}
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("hello", _payload, socket) do
    {:reply, {:ok, %{message: "world"}}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # def handle_info(%Broadcast{topic: _, event: ev, payload: payload}, socket) do
  #def handle_info(%Broadcast{topic: _, event: ev, payload: payload}, socket) do
  def handle_info(:after_join, socket) do
    # IEx.pry
    broadcast! socket, "new_msg", %{user_name: "System", body: "Welcome #{socket.assigns[:user_name]}", timestamp: :os.system_time(:milli_seconds)}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
