defmodule Fixxon.ProductionTest do
  use Fixxon.DataCase

  alias Fixxon.Production

  describe "batches" do
    alias Fixxon.Production.Batch

    import Fixxon.ProductionFixtures
    import Fixxon.UsersFixtures

    @invalid_attrs %{count: nil, batch_type: nil, button_type: nil, order_number: nil}

    test "list_batches/0 returns all batches" do
      user = admin_user_fixture()
      batch = batch_fixture(user)
      assert Production.list_batches() == [batch]
    end

    test "get_batch!/1 returns the batch with given id" do
      user = admin_user_fixture()
      batch = batch_fixture(user)
      assert Production.get_batch!(batch.id) == batch
    end

    test "create_batch/2 with valid data creates a batch" do
      valid_attrs = %{
        count: 42,
        batch_type: :order,
        button_type: :names,
        order_number: "some order_number"
      }

      user = admin_user_fixture()
      assert {:ok, %Batch{} = batch} = Production.create_batch(valid_attrs, user)
      assert batch.count == 42
      assert batch.batch_type == :order
      assert batch.button_type == :names
      assert batch.order_number == "some order_number"
    end

    test "create_batch/2 with invalid data returns error changeset" do
      user = admin_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Production.create_batch(@invalid_attrs, user)
    end

    test "update_batch/2 with valid data updates the batch" do
      user = admin_user_fixture()
      batch = batch_fixture(user)

      update_attrs = %{
        count: 43,
        batch_type: :stock,
        button_type: :numbers,
        order_number: nil
      }

      assert {:ok, %Batch{} = batch} = Production.update_batch(batch, update_attrs)
      assert batch.count == 43
      assert batch.batch_type == :stock
      assert batch.button_type == :numbers
      assert batch.order_number == nil
    end

    test "update_batch/2 with invalid data returns error changeset" do
      user = admin_user_fixture()
      batch = batch_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Production.update_batch(batch, @invalid_attrs)
      assert batch == Production.get_batch!(batch.id)
    end

    test "delete_batch/1 deletes the batch" do
      user = admin_user_fixture()
      batch = batch_fixture(user)
      assert {:ok, %Batch{}} = Production.delete_batch(batch)
      assert_raise Ecto.NoResultsError, fn -> Production.get_batch!(batch.id) end
    end

    test "change_batch/1 returns a batch changeset" do
      user = admin_user_fixture()
      batch = batch_fixture(user)
      assert %Ecto.Changeset{} = Production.change_batch(batch)
    end
  end
end
