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
    posts = Posts.list_posts!(actor: user, page: [limit: 10]).results

    socket =
      socket
      |> assign(posts: posts)

    {:noreply, socket}
  end
end
