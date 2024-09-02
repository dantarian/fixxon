defmodule Fixxon.Repo.Migrations.CreateBatches do
  use Ecto.Migration

  def change do
    create_batch_type_query = "CREATE TYPE batch_type AS ENUM ('stock', 'order')"
    drop_batch_type_query = "DROP TYPE batch_type"
    execute(create_batch_type_query, drop_batch_type_query)

    create_button_type_query = "CREATE TYPE button_type AS ENUM ('names', 'numbers')"
    drop_button_type_query = "DROP TYPE button_type"
    execute(create_button_type_query, drop_button_type_query)

    create table(:batches, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :batch_type, :batch_type, null: false
      add :button_type, :button_type, null: false
      add :order_number, :string
      add :count, :integer, null: false
      add :user_id, references(:users, on_delete: :restrict, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:batches, [:user_id])
  end
end
