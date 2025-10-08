defmodule MalinWeb.PostLive.Edit do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(uploaded_files: [])
      |> allow_upload(:image_url, accept: ~w(image/jpeg image/heic image/png), max_entries: 1)
      |> allow_upload(:gallery_images,
        accept: ~w(image/jpeg image/heic image/png),
        max_entries: 7
      )

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
          post = Ash.get!(Malin.Posts.Post, params["id"], action: :list, actor: socket.assigns.current_user)

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
            tags_input: existing_tags,
            existing_image: post.image_url
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

    _updated_params = Map.put(params, "tags", tags)

    {updated_params, uploaded_files} = process_uploads(socket, params)

    case AshPhoenix.Form.submit(socket.assigns.form, params: updated_params) do
      {:ok, _posts} ->
        socket =
          socket
          |> put_flash(
            :info,
            if(Map.has_key?(socket.assigns, :posts),
              do: "Posts updated successfully",
              else: "Post created successfully"
            )
          )
          |> update(:uploaded_files, &(&1 ++ uploaded_files))

        # Redirect after successful creation/update
        if Map.has_key?(socket.assigns, :product) do
          {:noreply, socket}
        else
          {:noreply, push_redirect(socket, to: ~p"/admin/posts")}
        end

      {:error, form} ->
        socket =
          socket
          |> put_flash(:error, "Could not save Reseller")
          |> assign(:form, form)

        {:noreply, socket}
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(err), do: "Error: #{inspect(err)}"

  # Helper function to process uploads
  defp process_uploads(socket, params) do
    # Process main image upload
    {params, main_urls} = process_main_image_upload(socket, params)

    # Process gallery image uploads
    {params, gallery_urls} = process_gallery_image_uploads(socket, params)

    {params, main_urls ++ gallery_urls}
  end

  defp process_main_image_upload(socket, params) do
    uploaded_urls =
      consume_uploaded_entries(socket, :image_url, fn %{path: path}, entry ->
        # Upload file to S3
        image_url = Malin.Uploaders.S3Uploader.upload_file(path, entry.client_name)

        # Delete old file if applicable
        old_url =
          if Map.has_key?(socket.assigns, :news) do
            socket.assigns.news.image_url()
          else
            nil
          end

        Malin.Uploaders.S3Uploader.delete_old_file(old_url, image_url)
        {:ok, image_url}
      end)

    # If we have any uploaded files, update the params with the first one
    if uploaded_urls != [] do
      {Map.put(params, "image_url", List.first(uploaded_urls)), uploaded_urls}
    else
      {params, []}
    end
  end

  defp process_gallery_image_uploads(socket, params) do
    # Process gallery image uploads if any
    _gallery_params = params["gallery"] || %{}

    gallery_urls =
      consume_uploaded_entries(socket, :gallery_images, fn %{path: path}, entry ->
        # Upload file to S3
        image_url = Malin.Uploaders.S3Uploader.upload_file(path, entry.client_name)
        {:ok, %{url: image_url, filename: entry.client_name}}
      end)

    if gallery_urls != [] do
      # Create photos entries for each uploaded gallery image
      photos_params =
        Enum.map(gallery_urls, fn %{url: url, filename: filename} ->
          %{
            "title" => filename,
            "description" => "",
            "image_url" => url
          }
        end)

      # If we already have photos in the params, merge with the new ones
      existing_photos = params["photos"] || []
      updated_photos = existing_photos ++ photos_params

      # Update the params with the gallery photos
      updated_params = Map.put(params, "photos", updated_photos)

      {updated_params, Enum.map(gallery_urls, fn %{url: url} -> url end)}
    else
      {params, []}
    end
  end
end
