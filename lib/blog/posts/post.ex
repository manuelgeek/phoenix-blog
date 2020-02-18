defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Blog.Accounts.User
  alias Blog.Categories.Category
  alias Blog.Posts.Tag
  alias Blog.Posts.Comment

  schema "posts" do
    field :body, :string
    field :image, :string
    field :img_file, :any, virtual: true
    field :tagged, :string, virtual: true
    field :slug, :string
    field :status, :boolean, default: true
    field :title, :string

    belongs_to :user, User
    belongs_to :category, Category
    has_many :comments, Comment, on_delete: :delete_all
    many_to_many :tags, Tag, join_through: "posts_tags"

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post

    IO.inspect(
      post
      |> cast(attrs, [:title, :slug, :body, :status, :img_file, :tagged, :user_id, :category_id])
      #    |> cast_assoc(:tags, with: &BlogWeb.Posts.Tag.changeset/2)
      |> validate_required([:title, :slug, :body, :img_file, :status, :tagged, :category_id])
      |> unique_constraint(:slug)
      |> add_image
    )
  end

  defp add_image(
         %Ecto.Changeset{valid?: true, changes: %{img_file: image, slug: slug}} = changeset
       ) do
    image = upload_image(image, slug)
    changeset = put_change(changeset, :image, image)
    IO.inspect(changeset)
  end

  defp add_image(changeset), do: changeset

  defp upload_image(image, slug) do
    File.mkdir_p!(Path.dirname("priv/static/media/"))
    extension = Path.extname(image.filename)
    img_name = "/media/#{slug}-post#{extension}"
    img_path = "priv/static#{img_name}"
    File.cp(image.path, img_path)
    img_name
  end
end
