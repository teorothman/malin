defmodule MalinWeb.PostLive.Show do
  use MalinWeb, :live_view

  def handle_params(unsigned_params, _uri, socket) do
    {:ok, post} =
      Ash.get(Malin.Posts.Post, unsigned_params["id"], actor: socket.assigns.current_user)

    {:noreply, assign(socket, post: post)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center space-y-6 lg:space-y-12 mb-12">
      <div class="w-full bg-cover bg-center bg-neutral-800 aspect-news-card "></div>
      <div class="prose p-3 lg:p-0 w-full max-w-4xl flex flex-col space-y-2 items-start ">
        <.link :if={@current_user != nil && @current_user.role == :admin} navigate={~p"/admin/post/#{@post.id}/edit"}>
          <.button class="bg-selected">Edit<.icon name="hero-pencil" /></.button>
        </.link>
        <.link patch={~p"/"} class="text-accent text-sm -mt-4 flex items-center gap-1">
          <.icon name="hero-arrow-left" class="w-4 h-4" /> Back
        </.link>

        <h1 class="text-2xl lg:text-4xl">{@post.title}</h1>
        <span class="text-zinc-500"></span>
        <p class="text-lg text-zinc-400 pt-4">{@post.text}</p>
        <div>
          <p class="text-sm">By: Malin Hägg</p>
          <div class="text-sm">Category: {@post.category.name}</div>
          <div class="flex gap-2">
            <p class="py-2">Tags:</p>
            <div :for={post <- @post.tags}>
              <p class="text-sm bg-selected/10 px-2 py-2 rounded-full">{post.name}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
