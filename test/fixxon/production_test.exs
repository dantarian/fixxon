defmodule Fixxon.ProductionTest do
  use Fixxon.DataCase

  alias Fixxon.Production

  describe "batches" do
    alias Fixxon.Production.Batch

    import Fixxon.ProductionFixtures

    @invalid_attrs %{count: nil, type: nil, stock: nil, order_number: nil}

    test "list_batches/0 returns all batches" do
      batch = batch_fixture()
      assert Production.list_batches() == [batch]
    end

    test "get_batch!/1 returns the batch with given id" do
      batch = batch_fixture()
      assert Production.get_batch!(batch.id) == batch
    end

    test "create_batch/1 with valid data creates a batch" do
      valid_attrs = %{count: 42, type: :names, stock: true, order_number: "some order_number"}

      assert {:ok, %Batch{} = batch} = Production.create_batch(valid_attrs)
      assert batch.count == 42
      assert batch.type == :names
      assert batch.stock == true
      assert batch.order_number == "some order_number"
    end

    test "create_batch/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Production.create_batch(@invalid_attrs)
    end

    test "update_batch/2 with valid data updates the batch" do
      batch = batch_fixture()
      update_attrs = %{count: 43, type: :numbers, stock: false, order_number: "some updated order_number"}

      assert {:ok, %Batch{} = batch} = Production.update_batch(batch, update_attrs)
      assert batch.count == 43
      assert batch.type == :numbers
      assert batch.stock == false
      assert batch.order_number == "some updated order_number"
    end

    test "update_batch/2 with invalid data returns error changeset" do
      batch = batch_fixture()
      assert {:error, %Ecto.Changeset{}} = Production.update_batch(batch, @invalid_attrs)
      assert batch == Production.get_batch!(batch.id)
    end

    test "delete_batch/1 deletes the batch" do
      batch = batch_fixture()
      assert {:ok, %Batch{}} = Production.delete_batch(batch)
      assert_raise Ecto.NoResultsError, fn -> Production.get_batch!(batch.id) end
    end

    test "change_batch/1 returns a batch changeset" do
      batch = batch_fixture()
      assert %Ecto.Changeset{} = Production.change_batch(batch)
    end
  end
end
