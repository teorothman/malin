defmodule MalinWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  alias AshAuthentication.Phoenix.Components

  override Components.Banner do
    set :class, "hidden"
    set :image_url, nil
    set :dark_image_url, nil
  end

  override Components.Password.Input do
    set :submit_class, "bg-brand w-full px-4 py-2 rounded-full text-sm mt-4 text-black"
    set :label_class, "text-white text-sm"
    set :input_class, "text-black p-2 rounded-lg border border-accent"
    set :field_class, "flex flex-col space-y-2"
  end

  override Components.SignIn do
    set :root_class, "custom-sign-in-class"
    set :show_banner, false
  end
end
