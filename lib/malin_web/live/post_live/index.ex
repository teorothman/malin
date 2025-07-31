defmodule MalinWeb.PostLive.Index do
  use MalinWeb, :live_view

  alias Malin.Posts

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(page_title: "Post")

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    user = socket.assigns.current_user

    socket =
      case socket.assigns.live_action do
        :admin ->
          posts = Posts.list_posts_admin!(actor: user, page: [limit: 10]).results

          assign(socket, posts: posts)

        :index ->
          posts = Posts.list_posts!(actor: user, page: [limit: 10]).results

          assign(socket, posts: posts)
      end

    {:noreply, socket}
  end
end
