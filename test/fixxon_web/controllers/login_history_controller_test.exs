defmodule FixxonWeb.LoginHistoryControllerTest do
  use FixxonWeb.ConnCase

  import Fixxon.UsersFixtures

  describe "login history with data" do
    setup [:create_user, :authenticate, :record_logins]

    test "renders", %{conn: conn} do
      conn = get(conn, ~p"/admin/logins")
      assert html_response(conn, 200) =~ "Login History"
    end
  end

  describe "login history with no data" do
    setup [:create_user, :authenticate]

    test "renders", %{conn: conn} do
      conn = get(conn, ~p"/admin/logins")
      assert html_response(conn, 200) =~ "Login History"
    end
  end

  defp create_user(_) do
    user = admin_user_fixture()
    %{user: user}
  end

  defp authenticate(%{conn: conn, user: user}) do
    conn = Pow.Plug.assign_current_user(conn, user, otp_app: :fixxon)
    %{conn: conn}
  end

  defp record_logins(%{user: user}) do
    login_fixture(user)
    login_fixture(user)
    :ok
  end
end
