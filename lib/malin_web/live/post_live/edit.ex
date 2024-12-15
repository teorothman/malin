defmodule MalinWeb.PostLive.Edit do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    categories = Ash.read!(Malin.Categories.Category)

    socket =
      case socket.assigns.live_action do
        :new ->
          form =
            Malin.Posts.Post
            |> AshPhoenix.Form.for_create(:create,
              actor: socket.assigns.current_user
            )
            |> to_form()

          assign(socket, form: form, page_title: "New Post", categories: categories)

        :edit ->
          post = Ash.get!(Malin.Posts.Post, params["id"], actor: socket.assigns.current_user)

          form =
            post
            |> AshPhoenix.Form.for_update(:update,
              actor: socket.assigns.current_user
            )
            |> to_form(post)

          assign(socket, form: form, page_title: "Edit Post", post: post, categories: categories)
      end

    {:noreply, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/")}

      {:error, form} ->
        IO.inspect(form, label: "Form with Errors")
        {:noreply, assign(socket, form: form)}
    end
  end
end
