defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Accounts.User
  alias Blog.Categories.Category

  schema "posts" do
    field :body, :string
    field :image, :string
    field :slug, :string
    field :status, :boolean, default: true
    field :title, :string

    belongs_to :user, User
    belongs_to :category, Category

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :slug, :body, :status, :image, :user_id, :category_id,:category])
#    |> cast_assoc(attrs, :category)
    |> validate_required([:title, :slug, :body, :status, :image, :category])
    |> unique_constraint(:slug)
  end
end
