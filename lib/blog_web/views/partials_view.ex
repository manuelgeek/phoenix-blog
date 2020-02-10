defmodule BlogWeb.PartialsView do
  use BlogWeb, :view
  alias Blog.Categories
  
  def categories do
    categories = Categories.list_active_categories()
#    IO.inspect categories
  end
end
