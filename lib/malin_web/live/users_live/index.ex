defmodule MalinWeb.UserLive.Index do
  use MalinWeb, :live_view

  require Ash.Query

  alias Malin.Accounts.User

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(page_title: "Admin - Users")

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    socket =
      case socket.assigns.live_action do
        :index ->
          users =
            User
            |> Ash.read!(actor: socket.assigns.current_user, authorize?: false)

          socket
          |> assign(users: users)
      end

    {:noreply, socket}
  end
end
