defmodule MalinWeb.Plugs.AdminAuth do
  use MalinWeb, :controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      %Malin.Accounts.User{role: :admin} ->
        conn

      _ ->
        conn
        |> put_status(401)
        |> json(%{message: "Unauthorized"})
        |> halt()
    end
  end
end
