defmodule MalinWeb.MessageLive.Index do
  use MalinWeb, :live_view

  alias Malin.Messages.Message

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(page_title: "Messages")

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    messages =
      Malin.Messages.list_messages!(
        actor: socket.assigns.current_user,
        load: [:user]
      )

    unread_messages =
      Malin.Messages.list_unread!(
        actor: socket.assigns.current_user,
        load: [:user]
      )

    socket =
      socket
      |> assign(messages: messages)
      |> assign(unread_count: length(unread_messages))

    {:noreply, socket}
  end

  def handle_event("toggle_read", %{"id" => message_id}, socket) do
    case Malin.Messages.get_by_id(message_id, actor: socket.assigns.current_user) do
      {:ok, message} ->
        IO.inspect(message.read_at, label: "Current read_at value")

        case Malin.Messages.toggle_read(message, actor: socket.assigns.current_user) do
          {:ok, updated_message} ->
            IO.inspect(updated_message.read_at, label: "New read_at value")
            send(self(), :refresh_messages)
            {:noreply, socket}

          {:error, error} ->
            IO.inspect(error, label: "Toggle read error")
            {:noreply, put_flash(socket, :error, "Kunde inte uppdatera meddelandet")}
        end

      {:error, error} ->
        IO.inspect(error, label: "Get message error")
        {:noreply, put_flash(socket, :error, "Meddelande ej funnet")}
    end
  end

  def handle_info(:refresh_messages, socket) do
    handle_params(%{}, "", socket)
  end
end
