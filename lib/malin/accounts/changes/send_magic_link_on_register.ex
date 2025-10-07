defmodule Malin.Accounts.Changes.SendMagicLinkOnRegister do
  @moduledoc """
  Sends a magic link email after a user registers via the application form.
  """
  use Ash.Resource.Change
  require Logger

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, user ->
      # Request a magic link for the newly registered user
      input =
        Malin.Accounts.User
        |> Ash.ActionInput.for_action(:request_magic_link, %{email: user.email})

      case Ash.run_action(input) do
        :ok ->
          {:ok, user}

        {:ok, _} ->
          {:ok, user}

        {:error, error} ->
          # Log the error but don't fail the registration
          Logger.error("Failed to send magic link on registration: #{inspect(error)}")
          {:ok, user}
      end
    end)
  end
end
