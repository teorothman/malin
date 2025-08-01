defmodule Malin.Analytics do
  use Ash.Domain

  resources do
    resource Malin.Analytics.Pageview
  end
end
