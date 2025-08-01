defmodule Malin.Accounts.Emails do
  @moduledoc """
  Module responsible for sending emails related to accounts.
  """

  import Swoosh.Email
  alias Malin.Mailer

  def send_magic_link_email(user_or_email, magic_link_url) do
    email_address = get_email(user_or_email)

    email =
      new()
      |> to(email_address)
      |> from("no-reply@teorothman.com")
      |> subject("Din inloggningslänk till Malin")
      |> html_body("""
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2>Logga in på Malin</h2>
        <p>Hej #{email_address}!</p>
        <p>Klicka på knappen nedan för att logga in:</p>
        <p style="text-align: center;">
          <a href="#{magic_link_url}"
             style="background-color: #007cba; color: white; padding: 12px 24px;
                    text-decoration: none; border-radius: 4px; display: inline-block;">
            Logga in
          </a>
        </p>
        <p>Denna länk går ut om 24 timmar.</p>
      </div>
      """)
      |> text_body(
        "Hej #{email_address}! Klicka på denna länk för att logga in: #{magic_link_url}"
      )

    Mailer.deliver(email)
  end

  # Updated to handle Ash.CiString
  defp get_email(%{email: email}), do: to_string(email)
  # Add this line
  defp get_email(%Ash.CiString{} = email), do: to_string(email)
  defp get_email(email) when is_binary(email), do: email
  # Fallback for any other type
  defp get_email(email), do: to_string(email)
end
