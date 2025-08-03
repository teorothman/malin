defmodule MalinWeb.AdminLive.Index do
  use MalinWeb, :live_view
  alias Malin.Posts
  alias Malin.Accounts

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(page_title: "Admin")
      |> load_dashboard_data()

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("refresh_data", _params, socket) do
    {:noreply, load_dashboard_data(socket)}
  end

  defp load_dashboard_data(socket) do
    total_posts = Posts.list_posts_admin!(actor: socket.assigns.current_user) |> length()
    total_users = Accounts.list_users_for_admin!(actor: socket.assigns.current_user) |> length()
    total_messages = Malin.Messages.list_messages!(actor: socket.assigns.current_user) |> length()

    total_unread =
      Malin.Messages.list_unread!(actor: socket.assigns.current_user) |> length()

    new_users_this_week =
      Accounts.list_users_this_week!(actor: socket.assigns.current_user) |> length()

    socket
    |> assign(:total_posts, total_posts)
    |> assign(:total_users, total_users)
    |> assign(:new_users_this_week, new_users_this_week)
    |> assign(:total_messages, total_messages)
    |> assign(:total_unread, total_unread)
  end
end
