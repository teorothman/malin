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
      |> subject("Din inloggningslänk")
      |> html_body("""
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 40px 20px;">
        <div style="text-align: center; margin-bottom: 40px;">
          <h1 style="color: #000000; font-size: 28px; font-weight: 700; margin: 0 0 16px 0; letter-spacing: -0.5px;">
            Välkommen tillbaka
          </h1>
          <p style="color: #4a5568; font-size: 16px; line-height: 1.6; margin: 0;">
            Klicka på knappen nedan för att logga in på ditt konto.
          </p>
        </div>

        <div style="text-align: center; margin: 40px 0;">
          <a href="#{magic_link_url}"
             style="background-color: #000000; color: #ffffff; padding: 16px 32px;
                    text-decoration: none; border-radius: 4px; display: inline-block;
                    font-weight: 600; font-size: 16px; transition: all 0.3s ease;">
            Logga in
          </a>
        </div>

        <div style="margin-top: 40px; padding-top: 24px; border-top: 1px solid #e2e8f0;">
          <p style="color: #718096; font-size: 14px; line-height: 1.6; margin: 0 0 12px 0;">
            Denna länk är giltig i 24 timmar och kan endast användas en gång.
          </p>
          <p style="color: #718096; font-size: 14px; line-height: 1.6; margin: 0;">
            Om du inte begärt denna inloggningslänk kan du ignorera detta mejl.
          </p>
        </div>

        <div style="margin-top: 40px; padding-top: 24px; border-top: 1px solid #e2e8f0; text-align: center;">
          <p style="color: #a0aec0; font-size: 12px; margin: 0;">
            Med vänlig hälsning,<br>
            Malin Högberg
          </p>
        </div>
      </div>
      """)
      |> text_body("""
      Välkommen tillbaka!

      Klicka på denna länk för att logga in: #{magic_link_url}

      Denna länk är giltig i 24 timmar och kan endast användas en gång.

      Om du inte begärt denna inloggningslänk kan du ignorera detta mejl.

      Med vänlig hälsning,
      Malin Högberg
      """)

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
