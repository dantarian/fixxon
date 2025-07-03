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
  @update_password_attrs %{password: "password123", password_confirmation: "password123"}
  @invalid_password_attrs %{password: "password123", password_confirmation: "mismatch"}
  @admin_role_attrs %{role: "admin"}
  @non_admin_role_attrs %{role: "user"}
  @invalid_role_attrs %{role: "unknown"}
  @active_state_attrs %{state: "active"}
  @inactive_state_attrs %{state: "inactive"}
  @invalid_state_attrs %{state: "unknown"}

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
      response_conn = post(conn, ~p"/admin/users", user: @create_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"

      response_conn = get(conn, ~p"/admin/users")
      assert html_response(response_conn, 200) =~ "some name"
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
      response_conn = put(conn, ~p"/admin/users/#{user}", user: @update_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"

      response_conn = get(conn, ~p"/admin/users")
      assert html_response(response_conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/admin/users/#{user}", user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "edit password" do
    setup [:create_admin_user, :authenticate_as_admin, :create_user]

    test "renders form for editing chosen user's password", %{conn: conn, user: user} do
      conn = get(conn, ~p"/admin/users/#{user}/password")
      assert html_response(conn, 200) =~ "Change Password"
    end
  end

  describe "update password" do
    setup [:create_admin_user, :authenticate_as_admin, :create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      response_conn = patch(conn, ~p"/admin/users/#{user}/password", user: @update_password_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = patch(conn, ~p"/admin/users/#{user}/password", user: @invalid_password_attrs)
      assert response = html_response(conn, 200)
      assert response =~ "Change Password"
      assert response =~ "does not match confirmation"
    end
  end

  describe "update role" do
    setup [:create_admin_user, :authenticate_as_admin, :create_user, :create_other_admin_user]

    test "redirects when role is updated to admin", %{conn: conn, user: user} do
      response_conn = patch(conn, ~p"/admin/users/#{user}/role", user: @admin_role_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"

      response_conn = get(conn, ~p"/admin/users")
      assert {:ok, document} = html_response(response_conn, 200) |> Floki.parse_document()
      cell = document |> Floki.find("#user-row-#{user.id} td:nth-child(2)") |> Floki.raw_html()
      assert cell =~ "Admin"
    end

    test "redirects when role is updated to non-admin", %{conn: conn, other_admin_user: user} do
      response_conn = patch(conn, ~p"/admin/users/#{user}/role", user: @non_admin_role_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"

      response_conn = get(conn, ~p"/admin/users")
      assert {:ok, document} = html_response(response_conn, 200) |> Floki.parse_document()
      cell = document |> Floki.find("#user-row-#{user.id} td:nth-child(2)") |> Floki.raw_html()
      assert cell =~ "User"
    end

    test "shows error when request role is invalid", %{conn: conn, user: user} do
      response_conn = patch(conn, ~p"/admin/users/#{user}/role", user: @invalid_role_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"
      assert %{"error" => "Failed to update role."} = response_conn.assigns.flash
    end

    test "shows error when user attempts to modify their own role", %{
      conn: conn,
      admin_user: user
    } do
      response_conn = patch(conn, ~p"/admin/users/#{user}/role", user: @non_admin_role_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"

      assert %{"error" => "You cannot perform this operation on yourself."} =
               response_conn.assigns.flash
    end
  end

  describe "update state" do
    setup [:create_admin_user, :authenticate_as_admin, :create_user]

    test "redirects when active state is updated", %{conn: conn, user: user} do
      response_conn = patch(conn, ~p"/admin/users/#{user}/state", user: @inactive_state_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"

      response_conn = get(conn, ~p"/admin/users")
      assert {:ok, document} = html_response(response_conn, 200) |> Floki.parse_document()
      cell = document |> Floki.find("#user-row-#{user.id} td:nth-child(3)") |> Floki.raw_html()
      assert cell =~ "Inactive"

      response_conn = patch(conn, ~p"/admin/users/#{user}/state", user: @active_state_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"

      response_conn = get(conn, ~p"/admin/users")
      assert {:ok, document} = html_response(response_conn, 200) |> Floki.parse_document()
      cell = document |> Floki.find("#user-row-#{user.id} td:nth-child(3)") |> Floki.raw_html()
      assert cell =~ "Active"
    end

    test "shows error when request state is invalid", %{conn: conn, user: user} do
      response_conn = patch(conn, ~p"/admin/users/#{user}/state", user: @invalid_state_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"
      assert %{"error" => "Failed to update state."} = response_conn.assigns.flash
    end

    test "shows error when user attempts to modify their own state", %{
      conn: conn,
      admin_user: user
    } do
      response_conn = patch(conn, ~p"/admin/users/#{user}/state", user: @inactive_state_attrs)
      assert redirected_to(response_conn) == ~p"/admin/users"

      assert %{"error" => "You cannot perform this operation on yourself."} =
               response_conn.assigns.flash
    end
  end

  describe "delete user" do
    setup [:create_admin_user, :authenticate_as_admin, :create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      response_conn = delete(conn, ~p"/admin/users/#{user}")
      assert redirected_to(response_conn) == ~p"/admin/users"

      assert_error_sent :not_found, fn ->
        delete(conn, ~p"/admin/users/#{user}")
      end
    end

    test "renders errors when user attempts to delete themselves", %{conn: conn, admin_user: user} do
      response_conn = delete(conn, ~p"/admin/users/#{user}")
      assert redirected_to(response_conn) == ~p"/admin/users"

      assert %{"error" => "You cannot perform this operation on yourself."} =
               response_conn.assigns.flash
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

  defp create_other_admin_user(_) do
    user = admin_user_fixture()
    %{other_admin_user: user}
  end
end
