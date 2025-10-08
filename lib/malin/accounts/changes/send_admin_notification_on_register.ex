defmodule Malin.Accounts.Changes.SendAdminNotificationOnRegister do
  @moduledoc """
  Sends an email notification to the admin when a new user registers via the application form.
  """
  use Ash.Resource.Change
  require Logger

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, user ->
      # Send admin notification email
      case Malin.Accounts.Emails.send_new_application_notification(user) do
        {:ok, _} ->
          Logger.info("Admin notification sent for new application: #{user.email}")
          {:ok, user}

        {:error, error} ->
          # Log the error but don't fail the registration
          Logger.error("Failed to send admin notification for application: #{inspect(error)}")
          {:ok, user}
      end
    end)
  end
end
