defmodule Malin.Posts do
  use Ash.Domain

  resources do
    resource Malin.Posts.Post do
    end

    resource Malin.Posts.Comment
  end

  authorization do
    authorize :by_default
    require_actor? true
  end
end
