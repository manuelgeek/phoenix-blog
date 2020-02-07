defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  import BlogWeb.Authorize

  alias Blog.Posts
  alias Blog.Posts.Post
  alias Blog.Categories

  plug :user_check when action in [:new, :create]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, params) do
    page = Posts.list_posts(params)
#    IO.inspect page
    render(conn, "index.html", posts: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    categories = Categories.list_active_categories()
    render(conn, "new.html", changeset: changeset, categories: categories)
  end

  def create(conn, %{"post" => post_params}) do
    slug = slugified_title(post_params["title"])
#      image = upload_image(post_params["image"], slug)
#      post_params = Map.put(post_params, "image", image)
    post_params = Map.merge(post_params, %{"status" => true, "slug" => slug, "user_id" => conn.assigns.current_user.id})
    
    case Posts.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:success, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Categories.list_active_categories()
        render(conn, "new.html", changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_by_slug!(id)
#    post = Posts.get_post!(id)
    render(conn, "show.html", post: post)
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

  defp slugified_title(title) do
    title
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end
end
