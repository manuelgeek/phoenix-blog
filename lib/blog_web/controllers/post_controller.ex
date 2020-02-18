defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  import BlogWeb.Authorize

  alias Blog.Posts
  alias Blog.Tags
  alias Blog.Posts.Post
  alias Blog.Categories
  alias Blog.Helpers.Helper
  alias Blog.Accounts

  plug :user_check when action in [:new, :create]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, params) do
    page = Posts.list_posts(params)
    #    IO.inspect page
    render(conn, "index.html", posts: page.entries, page: page)
  end

  def tag(conn, params) do
    try do
      tag = Tags.get_by_name!(params["tag"])
      page = Posts.list_tag_posts(params, tag.name)
      render(conn, "index.html", posts: page.entries, page: page, title: tag.name)
    rescue
      Ecto.NoResultsError ->
        {:error, :not_found, "No result found"}
        Helper.nothing_found(conn)
    end
  end

  def category(conn, params) do
    try do
      category = Categories.get_by_slug!(params["category"])
      page = Posts.list_category_posts(params, category.name)
      render(conn, "index.html", posts: page.entries, page: page, title: category.name)
    rescue
      Ecto.NoResultsError ->
        {:error, :not_found, "No result found"}
        Helper.nothing_found(conn)
    end
  end

  def user(conn, params) do
    try do
      user = Accounts.get_by_username!(params["username"])
      page = Posts.list_user_posts(params, user.id)
      render(conn, "index.html", posts: page.entries, page: page, title: user.name)
    rescue
      Ecto.NoResultsError ->
        {:error, :not_found, "No result found"}
        Helper.nothing_found(conn)
    end
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    categories = Categories.list_active_categories()
    render(conn, "new.html", changeset: changeset, categories: categories)
  end

  def create(conn, %{"post" => post_params}) do
    slug = Helper.slugified_title(post_params["title"])

    post_params =
      Map.merge(post_params, %{
        "status" => true,
        "slug" => slug,
        "user_id" => conn.assigns.current_user.id
      })

    case Posts.create_post(post_params) do
      {:ok, post} ->
        Tags.associate_tags(post_params["tagged"], post)

        conn
        |> put_flash(:success, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Categories.list_active_categories()
        render(conn, "new.html", changeset: changeset, categories: categories)
    end
  end

  def show(conn, params) do
    #    %{"id" => id}
    post = Posts.get_by_slug!(params["id"])
    comments = Posts.list_comments(params, post.id)
    render(conn, "show.html", post: post, comments: comments)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
  end

  def create_comment(conn, params) do
    %{"post_slug" => post_slug, "comment" => comment_params} = params
    post = Posts.get_by_slug!(post_slug)

    comment_params =
      Map.merge(comment_params, %{"post_id" => post.id, "user_id" => conn.assigns.current_user.id})

    case Posts.create_comment(comment_params) do
      {:ok, _comment} ->
        conn
        |> put_flash(:success, "Comment created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        comments = Posts.list_comments(params, post.id)
        conn |> render("show.html", post: post, changeset: changeset, comments: comments)
    end
  end
end
