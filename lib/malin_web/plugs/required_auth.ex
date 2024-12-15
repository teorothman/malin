defmodule MalinWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias MalinWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _default) do
    user = conn.assigns[:current_user]

    if user do
      conn
    else
      conn
      |> put_flash(:error, "You need to sign in to access this page.")
      |> redirect(to: Routes.sign_in_path(conn, :new))
      |> halt()
    end
  end
end
