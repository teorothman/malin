defmodule Malin.Accounts do
  use Ash.Domain

  resources do
    resource Malin.Accounts.Token

    resource Malin.Accounts.User do
      define :get_user, action: :show, args: [:id]
      define :register, action: :register
      define :update_user, action: :update
      define :list_users, action: :read
      define :list_users_for_admin, action: :list_for_admin
      define :list_users_this_week, action: :list_this_week
    end

    resource Malin.Accounts.Notification do
      define :notifications_for_user, action: :for_user
      define :dismiss_notification, action: :destroy
    end
  end
end
