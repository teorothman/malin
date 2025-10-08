defmodule MalinWeb.PostLive.Show do
  use MalinWeb, :live_view

  def handle_params(unsigned_params, _uri, socket) do
    {:ok, post} =
      Ash.get(Malin.Posts.Post, unsigned_params["id"],
        action: :list,
        actor: socket.assigns.current_user
      )

    {:noreply, assign(socket, post: post)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center space-y-6 lg:space-y-12 mb-12 pt-24">
      <div class="w-full bg-cover bg-center bg-neutral-800 aspect-news-card "></div>
      <div class="prose p-3 lg:p-0 w-full max-w-4xl flex flex-col space-y-2 items-start ">
        <.link
          :if={@current_user != nil && @current_user.role == :admin}
          navigate={~p"/admin/post/#{@post.id}/edit"}
        >
          Edit<.icon name="hero-pencil" />
        </.link>
        <.link patch={~p"/posts"} class="text-accent text-sm -mt-4 flex items-center gap-1">
          <.icon name="hero-arrow-left" class="w-4 h-4 z-11" /> Back
        </.link>

        <img src={@post.image_url} alt="Blog Image" class="w-full h-94 object-cover" />

        <h1 class="text-2xl lg:text-4xl">{@post.title}</h1>
        <span class="text-zinc-500"></span>
        <.markdown content={@post.text} class="prose prose-lg max-w-none pt-4" />
        <div>
          <p class="text-sm font-semibold">By: Malin Hägg</p>
        </div>
      </div>
    </div>
    """
  end
end
