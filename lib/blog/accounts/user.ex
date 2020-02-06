defmodule Blog.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Blog.Sessions.Session
  alias Blog.Posts.Post

  @type t :: %__MODULE__{
    id: integer,
    email: String.t(),
    name: String.t(),
    username: String.t(),
    password_hash: String.t(),
    sessions: [Session.t()] | %Ecto.Association.NotLoaded{},
    inserted_at: DateTime.t(),
    updated_at: DateTime.t()
  }

  schema "users" do
    field :name, :string
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :posts, Post, on_delete: :delete_all
    has_many :sessions, Session, on_delete: :delete_all

    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email, :username, :name])
    |> validate_required([:email, :username, :name])
    |> unique_email
    |> unique_constraint(:username)
  end

  def create_changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password, :name, :username])
    |> validate_required([:email, :password, :username, :name])
    |> unique_email
    |> validate_password(:password)
    |> validate_confirmation(:password)
    |> unique_constraint(:username)
    |> put_pass_hash
  end

  defp unique_email(changeset) do
    changeset
    |> validate_format(
      :email,
      ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}$/
    )
    |> validate_length(:email, max: 255)
    |> unique_constraint(:email)
  end

  # In the function below, strong_password? just checks that the password
  # is at least 8 characters long.
  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  # for a more comprehensive password strength checker.
  defp validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  # If you are using Bcrypt or Pbkdf2, change Argon2 to Bcrypt or Pbkdf2
  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes:
      %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 5 do
    {:ok, password}
  end

  defp strong_password?(_), do: {:error, "The password is too short"}
end
