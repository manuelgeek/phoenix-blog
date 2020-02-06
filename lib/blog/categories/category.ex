defmodule Blog.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Posts.Post

  schema "categories" do
    field :name, :string
    field :slug, :string
    field :status, :boolean, default: false

    has_many :posts, Post, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :slug, :status])
    |> validate_required([:name, :slug, :status])
    |> unique_constraint(:slug)
  end
end
