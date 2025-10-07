defmodule MalinWeb.ApplicationLive.Index do
  use MalinWeb, :live_view

  alias Malin.Accounts.User

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    course = case params["course"] do
      "focus_360" -> :focus_360
      "flowmakers" -> :flowmakers
      _ -> :open
    end

    form =
      User
      |> AshPhoenix.Form.for_create(:register,
        api: Malin.Accounts,
        params: %{"course" => course}
      )

    socket =
      socket
      |> assign(page_title: "Apply")
      |> assign(form: form)

    {:noreply, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params, errors: false)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _user} ->
        form = AshPhoenix.Form.for_create(User, :register, api: Malin.Accounts)

        socket =
          socket
          |> put_flash(:info, "Application submitted successfully!")
          |> assign(form: form)

        {:noreply, push_navigate(socket, to: ~p"/ansok/success")}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
