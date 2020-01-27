defmodule BlogWeb.PageController do
  alias BlogWeb.Router.Helpers, as: Routes
  use BlogWeb, :controller

  def index(conn, _params) do
#    redirect(conn, Routes.post_path(conn, :index))
    render(conn, "index.html")
  end
end
