defmodule Blog.Posts.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Accounts.User
  alias Blog.Categories.Post

  schema "comments" do
    field :name, :string
    
    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:name, :user_id, :post_id])
    |> validate_required([:name])
  end
end
