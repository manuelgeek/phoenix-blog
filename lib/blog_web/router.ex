defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
    plug Phauxth.Remember, create_session_func: &BlogWeb.Auth.Utils.create_session/1
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlogWeb do
    pipe_through :browser

    get "/register", UserController, :new
    post "/register", UserController, :create
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    post "/logout", SessionController, :delete

    get "/", PostController, :index
    get "/tags/:tag", PostController, :tag
    get "/categories/:category", PostController, :category
    get "/posts/user/:username", PostController, :user
    post "/comments/create/:post_slug", PostController, :create_comment
    resources "/posts", PostController
    resources "/users", UserController, except: [:new, :create, :index]
    #    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/categories", CategoryController #except: [:show]
    get "/category/create", CategoryController, :new, as: :cat
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogWeb do
  #   pipe_through :api
  # end
end
