defmodule Malin.Accounts.User.Senders.SendMagicLinkEmail do
  @moduledoc """
  Sends a magic link email
  """

  use AshAuthentication.Sender
  use MalinWeb, :verified_routes

  @impl true
  def send(user_or_email, token, _) do
    magic_link_url = url(~p"/auth/user/magic_link/?token=#{token}")

    # Fixed: Use Malin.Accounts.Emails instead of Malin.Emails
    Malin.Accounts.Emails.send_magic_link_email(user_or_email, magic_link_url)

    :ok
  end
end
