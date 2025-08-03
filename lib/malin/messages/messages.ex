defmodule Malin.Messages do
  use Ash.Domain

  resources do
    resource Malin.Messages.Message do
      define :list_messages, action: :read
      define :list_unread, action: :list_unread
      define :get_by_id, action: :get_by_id, args: [:id]
      define :toggle_read, action: :toggle_read
    end
  end
end
