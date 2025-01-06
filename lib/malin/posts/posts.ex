defmodule Malin.Posts do
  use Ash.Domain

  resources do
    resource Malin.Posts.Post do
      define :list_posts, action: :read
      define :get_post, action: :read
      define :list_posts_admin, action: :list
    end

    resource Malin.Posts.Comment
    resource Malin.Posts.Form
  end

  authorization do
    authorize :by_default
    require_actor? true
  end
end
