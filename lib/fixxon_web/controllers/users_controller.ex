defmodule FixxonWeb.UsersController do
  use FixxonWeb, :controller

  alias Fixxon.{Users, Users.User}

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, :index, users: users, page_title: "Users")
  end

  def new(conn, _params) do
    changeset = Users.change_user(%User{})
    render(conn, :new, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    changeset = Users.get_user!(id) |> Users.change_user()
    render(conn, :edit, changeset: changeset)
  end

  def delete(conn, %{"id" => id}) do
    Users.get_user!(id) |> Users.delete_user()
    conn |> put_flash(:info, "User deleted.") |> redirect(~p"/admin/users")
  end
end
