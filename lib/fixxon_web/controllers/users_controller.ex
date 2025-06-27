defmodule FixxonWeb.UsersController do
  use FixxonWeb, :controller

  alias Fixxon.{Users, Users.User}

  plug :prevent_modify_current_user when action in [:make_admin, :deactivate, :delete]

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users, page_title: "Users")
  end

  def new(conn, _params) do
    changeset = Users.change_user_for_create(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Users.create(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: ~p"/admin/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.change_user_for_update(user)
    render(conn, :edit, user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    case Users.update(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/admin/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def edit_password(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.change_user_password(user)
    render(conn, :edit_password, user: user, changeset: changeset)
  end

  def update_password(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    case Users.update_password(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/admin/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def make_admin(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    case Users.set_admin_role(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/admin/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def make_non_admin(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    case Users.set_user_role(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/admin/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def activate(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    case Users.activate_user(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/admin/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def deactivate(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    case Users.deactivate_user(user) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: ~p"/admin/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    {:ok, _} = Users.get_user!(id) |> Users.delete_user()
    conn |> put_flash(:info, "User deleted successfully.") |> redirect(~p"/admin/users")
  end

  defp prevent_modify_current_user(conn, _opts) do
    current_user = Pow.Plug.current_user(conn)
    %{"id" => user_id} = conn.params

    if current_user.id == user_id, do: conn |> put_status(:conflict) |> halt(), else: conn
  end
end
