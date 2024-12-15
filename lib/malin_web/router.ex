defmodule MalinWeb.Router do
  use MalinWeb, :router

  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MalinWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/admin", MalinWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_roudes do
      live "/", AdminLive.Index
    end
  end

  scope "/", MalinWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {MalinWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {MalinWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {MalinWeb.LiveUserAuth, :live_no_user}
    end
  end

  scope "/admin", MalinWeb do
    pipe_through(:browser)

    ash_authentication_live_session :admin_only,
      on_mount: [{MalinWeb.LiveUserAuth, :admin}] do
      live "/post/new", PostLive.Edit, :new
    end
  end

  scope "/", MalinWeb do
    pipe_through :browser

    ash_authentication_live_session :all,
      on_mount: [{MalinWeb.LiveUserAuth, :live_user_optional}] do
      live "/", HomeLive.Index
    end

    auth_routes AuthController, Malin.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{MalinWeb.LiveUserAuth, :live_no_user}],
                  overrides: [MalinWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [MalinWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
  end

  # Other scopes may use custom stacks.
  # scope "/api", MalinWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:malin, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MalinWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
