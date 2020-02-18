defmodule BlogWeb.SessionController do
  use BlogWeb, :controller

  import BlogWeb.Authorize

  alias BlogWeb.Auth.Login
  alias Phauxth.Remember
  alias Blog.{Sessions, Sessions.Session}

  plug :guest_check when action in [:new, :create]

  def new(conn, _) do
    render(conn, "login.html")
  end

  def create(conn, %{"session" => params}) do
    case Login.verify(params) do
      {:ok, user} ->
        conn
        |> add_session(user, params)
        |> put_flash(:info, "User successfully logged in.")
        |> redirect(to: get_session(conn, :request_path) || Routes.post_path(conn, :index))

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: %{id: user_id}}} = conn, %{"id" => session_id}) do
    case Sessions.get_session(session_id) do
      %Session{user_id: ^user_id} = session ->
        Sessions.delete_session(session)

        conn
        |> delete_session(:phauxth_session_id)
        |> Remember.delete_rem_cookie()
        |> put_flash(:info, "User successfully logged out.")
        |> redirect(to: Routes.post_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Unauthorized")
        |> redirect(to: Routes.post_path(conn, :index))
    end
  end

  defp add_session(conn, user, params) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> delete_session(:request_path)
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
    |> add_remember_me(user.id, params)
  end

  # This function adds a remember_me cookie to the conn.
  # See the documentation for Phauxth.Remember for more details.
  defp add_remember_me(conn, user_id, %{"remember_me" => "true"}) do
    Remember.add_rem_cookie(conn, user_id)
  end

  defp add_remember_me(conn, _, _), do: conn
end
