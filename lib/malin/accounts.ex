defmodule Malin.Accounts do
  use Ash.Domain

  resources do
    resource Malin.Accounts.Token
    resource Malin.Accounts.User
  end
end
