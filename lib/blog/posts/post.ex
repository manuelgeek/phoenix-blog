defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :image, :string
    field :slug, :string
    field :status, :boolean, default: true
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug, :body, :status, :image])
    |> validate_required([:title, :slug, :body, :status, :image])
    |> unique_constraint(:slug)
  end
end
