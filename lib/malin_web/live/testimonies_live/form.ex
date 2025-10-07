defmodule MalinWeb.TestimoniesLive.Form do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    form =
      Malin.Testimonies.Testimony
      |> AshPhoenix.Form.for_create(:create,
        domain: Malin.Testimonies,
        actor: socket.assigns.current_user
      )
      |> to_form()

    socket
    |> assign(page_title: "Ny testimonial")
    |> assign(testimony: nil)
    |> assign(form: form)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    case Malin.Testimonies.get_testimony(id, actor: socket.assigns.current_user) do
      {:ok, testimony} ->
        form =
          testimony
          |> AshPhoenix.Form.for_update(:update,
            domain: Malin.Testimonies,
            actor: socket.assigns.current_user
          )
          |> to_form()

        socket
        |> assign(page_title: "Redigera testimonial")
        |> assign(testimony: testimony)
        |> assign(form: form)

      {:error, _error} ->
        socket
        |> put_flash(:error, "Testimonial ej funnet")
        |> push_navigate(to: ~p"/admin/testimonials")
    end
  end

  def handle_event("validate", %{"form" => form_params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, form_params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"form" => form_params}, socket) do
    form = socket.assigns.form

    case AshPhoenix.Form.submit(form, params: form_params, actor: socket.assigns.current_user) do
      {:ok, _testimony} ->
        {:noreply,
         socket
         |> put_flash(:info, "Testimonial sparad")
         |> push_navigate(to: ~p"/admin/testimonials")}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
