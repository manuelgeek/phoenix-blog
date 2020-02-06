defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  import BlogWeb.Authorize

  alias Blog.Posts
  alias Blog.Posts.Post

  plug :user_check when action in [:new, :create]
  plug :id_check when action in [:edit, :update, :delete]

  def index(conn, params) do
    page = Posts.list_posts(params)
    IO.inspect page.entries
    render(conn, "index.html", posts: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    assign(conn, :button, "Welcome Forward")
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    slug = slugified_title(post_params["title"])
#    if(post_params["image"] != nil) do
      image = upload_image(post_params["image"], slug)
#      IO.inspect image
      post_params = Map.put(post_params, "image", image)
#    end
    post_params = Map.merge(post_params, %{"status" => true, "slug" => slug, "user_id" => conn.assigns.current_user.id})
#    IO.inspect post_params
    case Posts.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:success, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :show, post.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
      IO.inspect changeset
        render(conn, "new.html", changeset: changeset)
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

  defp upload_image(image, slug) do
    File.mkdir_p!(Path.dirname("priv/static/media/"))
    extension = Path.extname(image.filename)
    img_name = "/media/#{slug}-post#{extension}"
    img_path = "priv/static#{img_name}"
    File.cp(image.path, img_path)
    img_name
  end
end
