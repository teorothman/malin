defmodule MalinWeb.UserLive.Index do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(page_title: "Admin")
      |> assign(search_term: "")
      |> assign(filter_role: "all")
      |> assign(modal_open: false)
      |> assign(selected_user: nil)
      |> assign(form: nil)

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    users = load_users(socket.assigns.search_term, socket.assigns.filter_role)
    total_users = Malin.Accounts.list_users!()

    {:noreply, assign(socket, users: users, total_users_count: length(total_users))}
  end

  def handle_event("search", %{"search" => %{"term" => term}}, socket) do
    users = load_users(term, socket.assigns.filter_role)

    {:noreply,
     socket
     |> assign(search_term: term)
     |> assign(users: users)}
  end

  def handle_event("filter_role", %{"role" => role}, socket) do
    users = load_users(socket.assigns.search_term, role)

    {:noreply,
     socket
     |> assign(filter_role: role)
     |> assign(users: users)}
  end

  def handle_event("open_user_modal", %{"user-id" => user_id}, socket) do
    user = Enum.find(socket.assigns.users, &(&1.id == user_id))

    # Create a form for updating the user - adjust this based on your form structure
    form = to_form(%{"role" => user.role, "application_note" => user.application_note || ""})

    {:noreply,
     socket
     |> assign(modal_open: true)
     |> assign(selected_user: user)
     |> assign(form: form)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(modal_open: false)
     |> assign(selected_user: nil)
     |> assign(form: nil)}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    # Validate form without submitting - adjust based on your validation logic
    form = to_form(params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("update_user", %{"form" => params}, socket) do
    case Malin.Accounts.update_user(socket.assigns.selected_user, params,
           actor: socket.assigns.current_user
         ) do
      {:ok, _user} ->
        users = load_users(socket.assigns.search_term, socket.assigns.filter_role)

        {:noreply,
         socket
         |> assign(:users, users)
         |> assign(:modal_open, false)
         |> assign(:selected_user, nil)
         |> assign(:form, nil)
         |> put_flash(:info, "Användare uppdaterad framgångsrikt!")}

      {:error, form} ->
        {:noreply, assign(socket, :form, to_form(form))}
    end
  end

  defp load_users(search_term, filter_role) do
    args = %{}
    args = if search_term != "", do: Map.put(args, :search_email, search_term), else: args

    args =
      if filter_role != "all",
        do: Map.put(args, :filter_role, String.to_atom(filter_role)),
        else: args

    case Malin.Accounts.list_users_for_admin(args) do
      {:ok, users} -> users
      users when is_list(users) -> users
      _ -> []
    end
  end

  defp role_badge_class(:admin), do: "bg-purple-100 text-purple-800"
  defp role_badge_class(:user), do: "bg-blue-100 text-blue-800"
  defp role_badge_class(:applicant), do: "bg-yellow-100 text-yellow-800"
  defp role_badge_class(_), do: "bg-gray-100 text-gray-800"

  defp format_role(role) do
    role |> Atom.to_string() |> String.capitalize()
  end
end
