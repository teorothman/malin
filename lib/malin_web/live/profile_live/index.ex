defmodule MalinWeb.ProfileLive.Index do
  use MalinWeb, :live_view

  alias Malin.Accounts.User

  def mount(_params, _session, socket) do
    # Create a form that accepts the message field as an argument
    form = AshPhoenix.Form.for_create(User, :register, domain: Malin.Accounts)

    socket =
      socket
      |> assign(page_title: "Kontakt")
      |> assign(form: form)

    {:ok, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params, errors: false)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    # Extract message from params
    message_content = params["message"]
    user_params = Map.drop(params, ["message"])

    # Create user first
    case AshPhoenix.Form.submit(socket.assigns.form, params: user_params) do
      {:ok, user} ->
        IO.inspect(user, label: "Created user")
        IO.inspect(message_content, label: "Message content")

        # Then create the message
        case create_message(user, message_content) do
          {:ok, message} ->
            IO.inspect(message, label: "Created message")
            form = AshPhoenix.Form.for_create(User, :register, domain: Malin.Accounts)

            socket =
              socket
              |> put_flash(
                :info,
                "Meddelande skickat! Du får en länk via email för att fortsätta konversationen."
              )
              |> assign(form: form)

            {:noreply, push_navigate(socket, to: ~p"/kontakt/success")}

          {:error, error} ->
            IO.inspect(error, label: "Message creation error")

            {:noreply,
             put_flash(socket, :error, "Något gick fel när meddelandet skulle skickas.")}
        end

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp create_message(user, content) do
    attrs = %{
      content: content,
      user_id: user.id
    }

    result =
      Ash.create(
        Message,
        attrs,
        domain: Malin.Messages
      )

    result
  end
end
