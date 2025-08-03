defmodule MalinWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """
  import Phoenix.Component
  use MalinWeb, :verified_routes

  def on_mount(:current_user, _params, session, socket) do
    socket =
      case session["user"] do
        nil ->
          assign(socket, :current_user, nil)

        user_string ->
          case load_user_from_ash_session(user_string) do
            {:ok, user} ->
              assign(socket, :current_user, user)

            _error ->
              assign(socket, :current_user, nil)
          end
      end

    {:cont, socket}
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:admin, _params, session, socket) do
    socket =
      if socket.assigns[:current_user] do
        socket
      else
        # AshAuthentication stores user as "user" key with "user?id=..." format
        case session["user"] do
          nil ->
            assign(socket, :current_user, nil)

          user_string ->
            case load_user_from_ash_session(user_string) do
              {:ok, user} ->
                assign(socket, :current_user, user)

              _error ->
                assign(socket, :current_user, nil)
            end
        end
      end

    current_user = socket.assigns[:current_user]

    if current_user && current_user.role == :admin do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end

  # Add this helper function to load user from AshAuthentication session format
  defp load_user_from_ash_session("user?id=" <> user_id) do
    # Use your existing user loading function
    case Malin.Accounts.get_user(user_id) do
      {:ok, user} -> {:ok, user}
      {:error, _} -> {:error, :not_found}
    end
  end

  defp load_user_from_ash_session(_), do: {:error, :invalid_format}
end
