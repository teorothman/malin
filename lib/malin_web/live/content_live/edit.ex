defmodule MalinWeb.ContentLive.Edit do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(uploaded_files: [])
      |> allow_upload(:file, accept: ~w(.pdf), max_entries: 1)

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      case socket.assigns.live_action do
        :new ->
          form =
            Malin.Content.ContentItem
            |> AshPhoenix.Form.for_create(:create, actor: socket.assigns.current_user)
            |> to_form()

          assign(socket,
            form: form,
            page_title: "New Content"
          )

        :edit ->
          content_item =
            Malin.Content.get_content_item!(params["id"], actor: socket.assigns.current_user, load: [:author])

          form =
            content_item
            |> AshPhoenix.Form.for_update(:update,
              domain: Malin.Content,
              actor: socket.assigns.current_user
            )
            |> to_form()

          assign(socket,
            form: form,
            page_title: "Edit Content",
            content_item: content_item
          )
      end

    {:noreply, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    # Process file uploads if any
    {updated_params, uploaded_files} = process_uploads(socket, params)

    case AshPhoenix.Form.submit(socket.assigns.form, params: updated_params) do
      {:ok, _content_item} ->
        socket =
          socket
          |> put_flash(:info, "Content saved successfully")
          |> update(:uploaded_files, &(&1 ++ uploaded_files))
          |> push_navigate(to: ~p"/admin/content")

        {:noreply, socket}

      {:error, form} ->
        socket =
          socket
          |> put_flash(:error, "Could not save content")
          |> assign(:form, form)

        {:noreply, socket}
    end
  end

  defp process_uploads(socket, params) do
    uploaded_urls =
      consume_uploaded_entries(socket, :file, fn %{path: path}, entry ->
        # Upload file to S3
        file_url = Malin.Uploaders.S3Uploader.upload_file(path, entry.client_name)
        {:ok, file_url}
      end)

    # If we have any uploaded files, update the params with the first one
    if uploaded_urls != [] do
      {Map.put(params, "file_url", List.first(uploaded_urls)), uploaded_urls}
    else
      {params, []}
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(err), do: "Error: #{inspect(err)}"
end
