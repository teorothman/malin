defmodule MalinWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  alias AshAuthentication.Phoenix.Components

  override Components.Banner do
    set :dark_image_url, nil
    set :image_url, nil
    set :href_url, nil
    set :text_class, "text-black dark:text-white text-2xl w-1/3 text-center"

    set :text,
        "Want to sign up for my newsletter? Enter your email below and submit 🥳 Want to log in and see my exclusive content? Enter your email below and check your mailbox! 🎉"
  end

  override Components.Password.Input do
    set :submit_class, "bg-brand w-full px-4 py-2 rounded-full text-sm mt-4 text-black"
    set :label_class, "text-white text-sm"
    set :input_class, "bg-white text-black p-2 rounded-lg  border-brand dark:bg-none"
    set :field_class, "flex flex-col space-y-2"
  end

  override Components.MagicLink do
    set :request_flash_text, "🥳 Check your inbox and click the link!"
    set :disable_button_text, "Go check your inbox!"
  end

  override Components.HorizontalRule do
    set :text, "testing 123 123 123"
  end

  # override Components.SignIn do
  #   set :root_class, ""
  #   set :show_banner, false
  # end

  # override Components.HorizontalRule do
  #   set :text, "test"
  # end
end
