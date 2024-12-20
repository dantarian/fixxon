defmodule FixxonWeb.EnsureRolePlugTest do
  use FixxonWeb.ConnCase

  alias FixxonWeb.EnsureRolePlug

  @opts ~w(admin)a
  @user %{id: 1, role: :user}
  @admin %{id: 2, role: :admin}

  setup do
    conn =
      build_conn()
      |> Plug.Conn.put_private(:plug_session, %{})
      |> Plug.Conn.put_private(:plug_session_fetch, :done)
      |> Pow.Plug.put_config(otp_app: :fixxon)
      |> fetch_flash()

    {:ok, conn: conn}
  end

  test "call/2 with no user", %{conn: conn} do
    opts = EnsureRolePlug.init(@opts)
    conn = EnsureRolePlug.call(conn, opts)

    assert conn.halted
    assert redirected_to(conn) == ~p"/"
  end

  test "call/2 with non-admin user", %{conn: conn} do
    opts = EnsureRolePlug.init(@opts)

    conn =
      conn
      |> Pow.Plug.assign_current_user(@user, otp_app: :fixxon)
      |> EnsureRolePlug.call(opts)

    assert conn.halted
    assert redirected_to(conn) == ~p"/"
  end

  test "call/2 with non-admin user and multiple roles", %{conn: conn} do
    opts = EnsureRolePlug.init(~w(user admin)a)

    conn =
      conn
      |> Pow.Plug.assign_current_user(@user, otp_app: :fixxon)
      |> EnsureRolePlug.call(opts)

    refute conn.halted
  end

  test "call/2 with admin user", %{conn: conn} do
    opts = EnsureRolePlug.init(@opts)

    conn =
      conn
      |> Pow.Plug.assign_current_user(@admin, otp_app: :fixxon)
      |> EnsureRolePlug.call(opts)

    refute conn.halted
  end
end
