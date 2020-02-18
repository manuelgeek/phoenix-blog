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

  def list_user_posts(params, user_id) do
    Post
    |> order_by(desc: :inserted_at)
    |> where([p], p.user_id == ^user_id)
    |> preload([:user, :category, :tags])
    |> Repo.paginate(params)
  end

  def list_tag_posts(params, tag) do
    Post
    |> order_by(desc: :inserted_at)
    |> join(:left, [p], c in assoc(p, :tags))
    |> where([p, c], c.name == ^tag)
    |> preload([p, c], [:user, :category, :tags])
    |> Repo.paginate(params)
  end

  def list_category_posts(params, category) do
    Post
    |> order_by(desc: :inserted_at)
    |> join(:left, [p], c in assoc(p, :category))
    |> where([p, c], c.name == ^category)
    |> preload([p, c], [:user, :category, :tags])
    |> Repo.paginate(params)
  end

  def get_post!(id), do: Repo.get!(Post, id) |> Repo.preload([:user, :category, :tags])

  def get_by_slug!(slug) do
    Repo.get_by!(Post, slug: slug) |> Repo.preload([:user, :category, :tags])
  end

  def get_latest_posts do
    query =
      from p in Post,
        order_by: [desc: p.inserted_at],
        limit: 3

    Repo.all(query)
  end

  def get_popular_posts do
    query =
      from p in Post,
        left_join: c in assoc(p, :comments),
        group_by: p.id,
        having: count(c.id) > 1,
        order_by: [desc: p.inserted_at],
        limit: 3

    Repo.all(query)
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

  alias Blog.Posts.Comment

  def list_comments(params, post_id) do
    Comment
    |> where([p], p.post_id == ^post_id)
    |> preload([:user])
    |> Repo.paginate(params)
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  def change_comment(%Comment{} = comment) do
    Comment.changeset(comment, %{})
  end
end
