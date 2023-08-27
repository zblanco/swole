defmodule BuffWeb.Router do
  use BuffWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BuffWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BuffWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", BuffWeb do
    pipe_through :api

    resources "/plants", PlantController, except: [:new, :edit]
  end
end
