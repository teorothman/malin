defmodule Malin.Accounts.Emails do
  @moduledoc """
  Module responsible for sending emails related to accounts.
  """

  import Swoosh.Email
  alias Malin.Mailer

  def send_magic_link_email(user_or_email, token) do
    email =
      new()
      |> to(get_email(user_or_email))
      |> from("no-reply@yourapp.com")
      |> subject("Your Magic Link")
      |> html_body("Hello, #{get_email(user_or_email)}! Click this link to sign in: #{token}")
      |> text_body("Hello, #{get_email(user_or_email)}! Click this link to sign in: #{token}")

    Mailer.deliver(email)
  end

  defp get_email(%{email: email}), do: email
  defp get_email(email), do: email
end
