defmodule BlogWeb.PostView do
  use BlogWeb, :view

  import Scrivener.HTML

  def date(time) do
    {:ok, final} = time |> Timex.format("{D} {Mshort}, {YYYY}")
    final
  end

  def shorten_body(body) do
    if String.length(body) > 200 do
      body = String.slice(body, 0..200)
      body <> "..."
    else
      body
    end
  end
end
