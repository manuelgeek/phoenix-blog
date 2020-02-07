defmodule BlogWeb.CategoryView do
  use BlogWeb, :view
  
  def status(status) do
    if status === true do
      content_tag(:label, "Active", class: "label label-success")
    else
      content_tag(:label, "Inactive", class: "label label-danger")
    end
  end
end
