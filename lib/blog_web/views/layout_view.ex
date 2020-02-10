defmodule BlogWeb.LayoutView do
  use BlogWeb, :view
  alias Blog.Categories

  def current_session(conn) do
    Plug.Conn.get_session(conn, :phauxth_session_id)
  end

  def categories do
    Categories.list_active_categories()
  end
end
