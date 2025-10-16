defmodule Malin.Content do
  use Ash.Domain

  resources do
    resource Malin.Content.ContentItem do
      define :list_content_items, action: :read
      define :get_content_item, action: :show, args: [:id]
      define :list_content_items_admin, action: :list
      define :create_content_item, action: :create
      define :update_content_item, action: :update
      define :delete_content_item, action: :destroy
    end
  end

  authorization do
    authorize :by_default
    require_actor? true
  end
end
