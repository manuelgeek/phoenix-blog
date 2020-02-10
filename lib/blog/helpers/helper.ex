defmodule Blog.Helpers.Helper do
  alias BlogWeb.ErrorView
  use BlogWeb, :controller
  
  def slugified_title(title) do
    title
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end
  
  def nothing_found(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render(:"404")
  end
  
end
