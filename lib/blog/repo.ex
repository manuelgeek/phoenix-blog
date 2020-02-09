defmodule Blog.Repo do
  use Ecto.Repo,
    otp_app: :blog,
    adapter: Ecto.Adapters.Postgres
    use Scrivener, page_size: 5

  def fetch_by(queryable, clauses, opts \\ []) do
    case get_by(queryable, clauses, opts) do
      nil ->
        {:error, :resource_not_found}
    
      resource ->
        {:ok, resource}
    end
  end

  def fetch(query) do
    case all(query) do
      [] -> {:error, query}
      [obj] -> {:ok, obj}
    end
  end
end
