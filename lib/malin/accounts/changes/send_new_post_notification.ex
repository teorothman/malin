defmodule Malin.Accounts.Changes.SendNewPostNotifications do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn changeset_before, post ->
      # Only send notifications if state is changing to :published
      should_send_notifications? =
        Ash.Changeset.changing_attribute?(changeset_before, :state) and
          post.state == :published

      if should_send_notifications? do
        {:ok, users} = Malin.Accounts.list_users()

        notification_data =
          users
          |> Enum.map(fn user ->
            %{user_id: user.id, post_id: post.id}
          end)

        # Bypass authorization since this is a system action
        # Enable notify? for real-time pubsub updates
        case Ash.bulk_create(notification_data, Malin.Accounts.Notification, :create,
               authorize?: false,
               notify?: true,
               return_errors?: true
             ) do
          %{status: :success} ->
            {:ok, post}

          %{errors: errors} ->
            IO.inspect(errors, label: "Bulk create errors")
            {:ok, post}
        end
      else
        {:ok, post}
      end
    end)
  end
end
