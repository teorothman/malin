defmodule Malin.Categories do
  use Ash.Domain

  resources do
    resource Malin.Categories.Tag
    resource Malin.Categories.Category
    resource Malin.Categories.PostTag
  end

  authorization do
    authorize :when_requested
    require_actor? false
  end
end
