defmodule FixxonWeb.DashboardControllerTest do
  use FixxonWeb.ConnCase

  import Fixxon.ProductionFixtures
  import Fixxon.UsersFixtures

  describe "dashboard with data" do
    setup [:create_user, :authenticate, :create_batches]

    test "renders", %{conn: conn} do
      conn = get(conn, ~p"/admin/dashboard")
      assert html_response(conn, 200) =~ "Dashboard"
    end
  end

  describe "dashboard with no data" do
    setup [:create_user, :authenticate]

    test "renders", %{conn: conn} do
      conn = get(conn, ~p"/admin/dashboard")
      assert html_response(conn, 200) =~ "Dashboard"
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

  defp create_batches(%{user: user}) do
    batch1 = batch_fixture(user, %{button_type: :names})
    batch2 = batch_fixture(user, %{button_type: :numbers})
    %{batches: [batch1, batch2]}
  end
end
