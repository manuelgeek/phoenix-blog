defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.Posts.Post
  
  def list_posts(params) do
    Post
    |> order_by(desc: :inserted_at)
#    |> join(:left, [p], c in assoc(p, :tags))
#    |> where([p, c], c.name == "edu")
#    |> preload([p, c], [:user, :category, :tags])
    |> preload([:user, :category, :tags])
    |> Repo.paginate(params)
#
  end
  
  def list_tag_posts(params, tag) do
    Post
    |> order_by(desc: :inserted_at)
    |> join(:left, [p], c in assoc(p, :tags))
    |> where([p, c], c.name == ^tag)
    |> preload([p, c], [:user, :category, :tags])
    |> Repo.paginate(params)
  end
  
  def get_post!(id), do: Repo.get!(Post, id)

  def get_by_slug!(slug) do
    Repo.get_by!(Post, slug: slug) |> Repo.preload([:user, :category, :tags])
  end
  
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end
  
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end
  
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end
  
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end

end
