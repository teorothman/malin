defmodule MalinWeb.CourseLive.Index do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    form =
      Malin.Posts.Form
      |> AshPhoenix.Form.for_create(:create, actor: socket.assigns.current_user)
      |> to_form()

    socket =
      assign(socket, form: form, page_title: "Ta kontroll över din tid", submit: false)

    {:noreply, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _post} ->
        {:noreply, assign(socket, submit: true)}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
