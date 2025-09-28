defmodule FixxonWeb.Router do
  use FixxonWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FixxonWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :admin do
    plug FixxonWeb.EnsureRolePlug, :admin
  end

  pipeline :record do
    plug FixxonWeb.RecordLoginPlug
  end

  pipeline :rate_limit_login do
    plug FixxonWeb.RateLimitLoginPlug
  end

  scope "/" do
    pipe_through :browser

    resources "/session", Pow.Phoenix.SessionController, singleton: true, only: [:new, :delete]
  end

  scope "/" do
    pipe_through [:browser, :record, :rate_limit_login]

    resources "/session", Pow.Phoenix.SessionController, singleton: true, only: [:create]
  end

  scope "/", Pow.Phoenix, as: "pow" do
    pipe_through [:browser, :protected]

    resources "/registration", RegistrationController,
      singleton: true,
      only: [:edit, :update]
  end

  scope "/", FixxonWeb do
    pipe_through [:browser, :protected]

    resources "/batches", BatchController, only: [:new, :create, :edit, :update]

    get "/", BatchController, :new
  end

  scope "/admin", FixxonWeb do
    pipe_through [:browser, :protected, :admin]

    resources "/batches", BatchController
    get "/logins", LoginHistoryController, :index
    get "/dashboard", DashboardController, :index
    resources "/users", UserController
    get "/users/:id/password", UserController, :edit_password
    patch "/users/:id/password", UserController, :update_password
    patch "/users/:id/role", UserController, :update_role
    patch "/users/:id/state", UserController, :update_state
  end

  # Other scopes may use custom stacks.
  # scope "/api", FixxonWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:fixxon, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FixxonWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
