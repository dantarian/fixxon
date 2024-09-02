defmodule FixxonWeb.BatchControllerTest do
  use FixxonWeb.ConnCase

  import Fixxon.ProductionFixtures

  @create_attrs %{count: 42, type: :names, stock: true, order_number: "some order_number"}
  @update_attrs %{count: 43, type: :numbers, stock: false, order_number: "some updated order_number"}
  @invalid_attrs %{count: nil, type: nil, stock: nil, order_number: nil}

  describe "index" do
    test "lists all batches", %{conn: conn} do
      conn = get(conn, ~p"/batches")
      assert html_response(conn, 200) =~ "Listing Batches"
    end
  end

  describe "new batch" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/batches/new")
      assert html_response(conn, 200) =~ "New Batch"
    end
  end

  describe "create batch" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/batches", batch: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/batches/#{id}"

      conn = get(conn, ~p"/batches/#{id}")
      assert html_response(conn, 200) =~ "Batch #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/batches", batch: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Batch"
    end
  end

  describe "edit batch" do
    setup [:create_batch]

    test "renders form for editing chosen batch", %{conn: conn, batch: batch} do
      conn = get(conn, ~p"/batches/#{batch}/edit")
      assert html_response(conn, 200) =~ "Edit Batch"
    end
  end

  describe "update batch" do
    setup [:create_batch]

    test "redirects when data is valid", %{conn: conn, batch: batch} do
      conn = put(conn, ~p"/batches/#{batch}", batch: @update_attrs)
      assert redirected_to(conn) == ~p"/batches/#{batch}"

      conn = get(conn, ~p"/batches/#{batch}")
      assert html_response(conn, 200) =~ "some updated order_number"
    end

    test "renders errors when data is invalid", %{conn: conn, batch: batch} do
      conn = put(conn, ~p"/batches/#{batch}", batch: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Batch"
    end
  end

  describe "delete batch" do
    setup [:create_batch]

    test "deletes chosen batch", %{conn: conn, batch: batch} do
      conn = delete(conn, ~p"/batches/#{batch}")
      assert redirected_to(conn) == ~p"/batches"

      assert_error_sent 404, fn ->
        get(conn, ~p"/batches/#{batch}")
      end
    end
  end

  defp create_batch(_) do
    batch = batch_fixture()
    %{batch: batch}
  end
end
