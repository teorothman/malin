defmodule MalinWeb.PostLive.Edit do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    categories = Ash.read!(Malin.Categories.Category)
    available_tags = Ash.read!(Malin.Categories.Tag)

    socket =
      case socket.assigns.live_action do
        :new ->
          form =
            Malin.Posts.Post
            |> AshPhoenix.Form.for_create(:create, actor: socket.assigns.current_user)
            |> to_form()

          assign(socket,
            form: form,
            page_title: "New Post",
            categories: categories,
            available_tags: available_tags,
            tags_input: ""
          )

        :edit ->
          post = Ash.get!(Malin.Posts.Post, params["id"], actor: socket.assigns.current_user)

          form =
            post
            |> AshPhoenix.Form.for_update(:update,
              domain: Malin.Posts,
              forms: [auto?: true],
              actor: socket.assigns.current_user
            )
            |> to_form()

          existing_tags =
            post.tags
            |> Enum.map(& &1.name)
            |> Enum.join(", ")

          assign(socket,
            form: form,
            page_title: "Edit Post",
            post: post,
            categories: categories,
            available_tags: available_tags,
            tags_input: existing_tags
          )
      end

    {:noreply, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form, tags_input: params["tags_input"] || "")}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    tags_input = Map.get(params, "tags_input", "")

    tags =
      tags_input
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&%{"name" => &1})

    updated_params = Map.put(params, "tags", tags)

    case AshPhoenix.Form.submit(socket.assigns.form, params: updated_params) do
      {:ok, _post} ->
        {:noreply, push_navigate(socket, to: ~p"/admin/posts")}

      {:error, form} ->
        {:noreply, assign(socket, form: form, tags_input: tags_input)}
    end
  end
end
