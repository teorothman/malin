defmodule Malin.Accounts do
  use Ash.Domain

  resources do
    resource Malin.Accounts.Token

    resource Malin.Accounts.User do
      define :get_user, action: :show, args: [:id]
      define :register, action: :register
      define :update_user, action: :update
    end
  end
end
