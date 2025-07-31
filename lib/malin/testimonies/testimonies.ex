defmodule Malin.Testimonies do
  use Ash.Domain

  resources do
    resource Malin.Testimonies.Testimony do
      define :list_testimonies, action: :read
      define :get_testimony, action: :read
      define :create_testimony, action: :create
      define :update_testimony, action: :update
      define :delete_testimony, action: :destroy
    end
  end
end
