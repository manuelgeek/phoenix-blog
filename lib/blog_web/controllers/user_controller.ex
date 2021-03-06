defmodule BlogWeb.UserController do
  use BlogWeb, :controller

  import BlogWeb.Authorize

  alias Phauxth.Log
  alias Blog.{Accounts, Accounts.User}
  alias Blog.Sessions
  alias Phauxth.Remember

  # the following plugs are defined in the controllers/authorize.ex file
  plug :user_check when action in [:index]
  plug :id_check when action in [:edit, :update, :delete, :show]

  def index(conn, _) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "auth/register.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        Log.info(%Log{user: user.id, message: "user created"})

        Accounts.create_account(%{
          "user_id" => user.id,
          "avatar" => "/dist/img/clients/client-1.jpg"
        })

        conn
        |> add_session(user, user_params)
        |> put_flash(:info, "User created successfully.")
        #        |> redirect(to: Routes.session_path(conn, :new))
        |> redirect(to: Routes.post_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        render(conn, "auth/register.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => username}) do
    user =
      if username == to_string(user.username), do: user, else: Accounts.get_by_username!(username)

    render(conn, "show.html", user: user)
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{
        "user" => user_params,
        "account" => account_params
      }) do
    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        account_params =
          Map.merge(account_params, %{
            "user_id" => user.id
          })

        case Accounts.update_account(user.account, account_params) do
          {:ok, _account} ->
            conn
            # |> add_session(user, user_params)
            |> put_flash(:info, "User updated successfully.")
            |> redirect(to: Routes.user_path(conn, :show, user.username))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", user: user, changeset: changeset)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    {:ok, _user} = Accounts.delete_user(user)

    conn
    |> delete_session(:phauxth_session_id)
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp add_session(conn, user, params) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> delete_session(:request_path)
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
    |> add_remember_me(user.id, params)
  end

  defp add_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    Remember.add_rem_cookie(conn, user_id)
  end

  defp add_remember_me(conn, _, _), do: conn
end
