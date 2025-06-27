defmodule FixxonWeb.UserControllerTest do
  use FixxonWeb.ConnCase

  import Fixxon.UsersFixtures

  @create_attrs %{
    username: "some name",
    password: "secret123",
    password_confirmation: "secret123"
  }
  @update_attrs %{username: "some updated name"}
  @invalid_attrs %{username: nil}

  describe "index" do
    setup [:create_admin_user, :authenticate_as_admin]

    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/admin/users")
      assert html_response(conn, 200) =~ "Users"
    end
  end

  describe "new user" do
    setup [:create_admin_user, :authenticate_as_admin]

    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/users/new")
      assert html_response(conn, 200) =~ "Add User"
    end
  end

  describe "create user" do
    setup [:create_admin_user, :authenticate_as_admin]

    test "redirects to list when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/users", user: @create_attrs)
      assert redirected_to(conn) == ~p"/admin/users"

      conn = get(conn, ~p"/admin/users")
      assert html_response(conn, 200) =~ "some name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/users", user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Add User"
    end
  end

  describe "edit user" do
    setup [:create_admin_user, :authenticate_as_admin, :create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, ~p"/admin/users/#{user}/edit")
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_admin_user, :authenticate_as_admin, :create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/admin/users/#{user}", user: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/users"

      conn = get(conn, ~p"/admin/users")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/admin/users/#{user}", user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_admin_user, :authenticate_as_admin, :create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, ~p"/admin/users/#{user}")
      assert redirected_to(conn) == ~p"/admin/users"

      assert_error_sent 404, fn ->
        delete(conn, ~p"/admin/users/#{user}")
      end
    end
  end

  defp authenticate_as_admin(%{conn: conn, admin_user: admin_user}) do
    conn = Pow.Plug.assign_current_user(conn, admin_user, otp_app: :fixxon)
    %{conn: conn}
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp create_admin_user(_) do
    user = admin_user_fixture()
    %{admin_user: user}
  end
end
