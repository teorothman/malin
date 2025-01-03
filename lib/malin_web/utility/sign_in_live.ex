defmodule MalinWeb.Utility.SignInLive do
  use MalinWeb, :live_view

  use AshAuthentication.Phoenix.Overrides.Overridable,
    root_class: "CSS class for the root `div` element.",
    sign_in_id: "Element ID for the `SignIn` LiveComponent."

  @moduledoc """
  A generic, white-label sign-in page.

  This live-view can be rendered into your app using the
  `AshAuthentication.Phoenix.Router.sign_in_route/1` macro in your router (or by
  using `Phoenix.LiveView.Controller.live_render/3` directly in your markup).

  This live-view finds all Ash resources with an authentication configuration
  (via `AshAuthentication.authenticated_resources/1`) and renders the
  appropriate UI for their providers using
  `AshAuthentication.Phoenix.Components.SignIn`.

  #{AshAuthentication.Phoenix.Overrides.Overridable.generate_docs()}
  """

  alias AshAuthentication.Phoenix.Components
  alias Phoenix.LiveView.{Rendered, Socket}

  @doc false
  @impl true
  def mount(_params, session, socket) do
    overrides =
      session
      |> Map.get("overrides", [AshAuthentication.Phoenix.Overrides.Default])

    socket =
      socket
      |> assign(page_title: "Sign In")
      |> assign(overrides: overrides)
      |> assign_new(:otp_app, fn -> nil end)
      |> assign(:path, session["path"] || "/")
      |> assign(:reset_path, session["reset_path"])
      |> assign(:register_path, session["register_path"])
      |> assign(:current_tenant, session["tenant"])

    {:ok, socket}
  end

  @impl true
  def handle_params(_, _uri, socket) do
    {:noreply, socket}
  end

  @doc false
  @impl true
  @spec render(Socket.assigns()) :: Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-[100dvh] pt-20 items-center justify-center">
      <div class="fixed top-0 left-0 right-0 h-16 bg-selecte flex items-center justify-center"></div>
      <div class="h-10 w-10 bg-red" />
      <div class="flex flex-col items-center">
        <h3 class="text-2xl">Sign In</h3>

        <.live_component
          module={Components.SignIn}
          otp_app={@otp_app}
          live_action={@live_action}
          path={@path}
          reset_path={@reset_path}
          register_path={@register_path}
          id={override_for(@overrides, :sign_in_id, "sign-in")}
          overrides={@overrides}
          current_tenant={@current_tenant}
        />

        <.link navigate="/register">
          <p class="text-accent text-xs mt-4">Create an account</p>
        </.link>
      </div>
    </div>
    """
  end
end
