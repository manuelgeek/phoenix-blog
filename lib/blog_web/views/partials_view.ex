defmodule BlogWeb.PartialsView do
  use BlogWeb, :view
  alias Blog.Categories
  alias Blog.Posts
  import Scrivener.HTML
  
  def categories do
    Categories.list_active_categories()
  end
  
  def latest_posts do
    Posts.get_latest_posts()
  end

  def date(time) do
    {:ok, final} = time |> Timex.format("{Mshort} {D}, {YYYY}")
    final
  end

  def hour(time) do
    {:ok, final} = time |> Timex.format("%l:%M %P", :strftime)
    final
  end
  
end
