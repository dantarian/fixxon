defmodule Fixxon.Production.Batch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "batches" do
    field :count, :integer
    field :batch_type, Ecto.Enum, values: [:stock, :order]
    field :button_type, Ecto.Enum, values: [:names, :numbers]
    field :order_number, :string
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(batch, attrs) do
    batch
    |> cast(attrs, [:batch_type, :button_type, :order_number, :count])
    |> validate_required([:batch_type, :button_type, :count])
    |> validate_number(:count, greater_than: 0)
    |> validate_order_number()
  end

  def user_changeset(batch, attrs) do
    batch
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end

  def validate_order_number(changeset) do
    case get_field(changeset, :batch_type) do
      :stock ->
        if field_missing?(changeset, :order_number),
          do: changeset,
          else: add_error(changeset, :order_number, "must not be supplied for stock batches")

      :order ->
        if field_missing?(changeset, :order_number),
          do: add_error(changeset, :order_number, "must be supplied for order batches"),
          else: changeset

      _ ->
        changeset
    end
  end
end
