defmodule Fixxon.Production.BatchTest do
  use Fixxon.DataCase

  alias Fixxon.Production.Batch

  @valid_attrs %{batch_type: :order, button_type: :names, count: 5, order_number: "1"}

  describe "validation" do
    test "no order number on stock batches" do
      changeset =
        Batch.changeset(
          %Batch{},
          Map.merge(@valid_attrs, %{
            batch_type: :stock
          })
        )

      assert {"must not be supplied for stock batches", _} = changeset.errors[:order_number]
    end

    test "order number must be present on order batches" do
      changeset =
        Batch.changeset(
          %Batch{},
          Map.merge(@valid_attrs, %{
            order_number: nil
          })
        )

      assert {"must be supplied for order batches", _} = changeset.errors[:order_number]
    end
  end
end
