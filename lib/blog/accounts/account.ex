defmodule Blog.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.Accounts.User
  alias Blog.Helpers.Helper

  schema "accounts" do
    field :avatar, :string
    field :bio, :string
    field :fb, :string
    field :tw, :string
    field :img_file, :any, virtual: true

    belongs_to :user, User
    timestamps()
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:avatar, :bio, :fb, :tw, :user_id])
    |> validate_required([:user_id, :avatar])
  end

  def update_changeset(account, attrs) do
    account
    |> cast(attrs, [:img_file, :bio, :fb, :tw, :user_id])
    |> validate_required([:user_id])
    |> add_avatar(account.avatar)
  end

  defp add_avatar(%Ecto.Changeset{valid?: true, changes: %{img_file: image}} = changeset, old_img) do
    rand = Helper.gen_reference()
    image = upload_image(image, rand)

    if old_img !== "/dist/img/clients/client-1.jpg" do
      remove_old_avatar(old_img)
    end

    put_change(changeset, :avatar, image)
  end

  defp add_avatar(changeset, _img), do: changeset

  def remove_old_avatar(old_img) do
    File.rm("priv/static#{old_img}")
  end

  defp upload_image(image, img_unique) do
    File.mkdir_p!(Path.dirname("priv/static/avatar/"))
    extension = Path.extname(image.filename)
    img_name = "/avatar/#{img_unique}-user#{extension}"
    img_path = "priv/static#{img_name}"
    File.cp(image.path, img_path)
    img_name
  end
end
