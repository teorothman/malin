defmodule MalinWeb.TestimoniesLive.Index do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(page_title: "Testimonials")

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    testimonies =
      Malin.Testimonies.list_testimonies!(
        actor: socket.assigns.current_user
      )

    socket =
      socket
      |> assign(testimonies: testimonies)

    {:noreply, socket}
  end

  def handle_event("delete_testimony", %{"id" => testimony_id}, socket) do
    case Malin.Testimonies.get_testimony(testimony_id, actor: socket.assigns.current_user) do
      {:ok, testimony} ->
        case Malin.Testimonies.delete_testimony(testimony, actor: socket.assigns.current_user) do
          :ok ->
            testimonies =
              Malin.Testimonies.list_testimonies!(
                actor: socket.assigns.current_user
              )

            {:noreply,
             socket
             |> assign(testimonies: testimonies)
             |> put_flash(:info, "Testimonial raderad")}

          {:error, _error} ->
            {:noreply, put_flash(socket, :error, "Kunde inte radera testimonial")}
        end

      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Testimonial ej funnet")}
    end
  end
end
