defmodule FixxonWeb.BatchControllerTest do
  use FixxonWeb.ConnCase

  import Fixxon.ProductionFixtures
  import Fixxon.UsersFixtures

  @create_attrs %{
    count: 42,
    button_type: :names,
    batch_type: :order,
    order_number: "some order_number"
  }
  @update_attrs %{
    count: 43,
    button_type: :numbers,
    batch_type: :stock,
    order_number: nil
  }
  @invalid_attrs %{count: nil, button_type: nil, batch_type: nil, order_number: nil}

  describe "new batch" do
    setup [:create_user, :authenticate]

    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/batches/new")
      assert html_response(conn, 200) =~ "Add Buttons"
    end
  end

  describe "create batch" do
    setup [:create_user, :authenticate]

    test "redirects to new when data is valid", %{conn: conn} do
      res_conn = post(conn, ~p"/batches", batch: @create_attrs)
      assert redirected_to(res_conn) == ~p"/batches/new"

      res_conn = get(conn, ~p"/batches/new")
      assert html_response(res_conn, 200) =~ "some order_number"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/batches", batch: @invalid_attrs)
      assert html_response(conn, 200) =~ "Failed to save the batch"
    end
  end

  describe "edit batch" do
    setup [:create_user, :authenticate, :create_batch]

    test "renders form for editing chosen batch", %{conn: conn, batch: batch} do
      conn = get(conn, ~p"/batches/#{batch}/edit")
      assert html_response(conn, 200) =~ "Edit Batch"
    end
  end

  describe "update batch" do
    setup [:create_user, :authenticate, :create_batch]

    test "redirects when data is valid", %{conn: conn, batch: batch} do
      res_conn = put(conn, ~p"/batches/#{batch}", batch: @update_attrs)
      assert redirected_to(res_conn) == ~p"/batches/new"

      res_conn = get(conn, ~p"/batches/new")
      assert html_response(res_conn, 200) =~ "Stock"
    end

    test "renders errors when data is invalid", %{conn: conn, batch: batch} do
      conn = put(conn, ~p"/batches/#{batch}", batch: @invalid_attrs)
      assert html_response(conn, 200) =~ "Failed to save the batch"
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

  defp create_batch(%{user: user}) do
    batch = batch_fixture(user)
    %{batch: batch}
  end
end
