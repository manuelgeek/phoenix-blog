defmodule BlogWeb.PostView do
  use BlogWeb, :view

  import Scrivener.HTML

  def date(time) do
    {:ok, final} = time |> Timex.format("{D} {Mshort}, {YYYY}")
    final
  end
end
