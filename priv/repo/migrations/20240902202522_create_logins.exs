defmodule Fixxon.Repo.Migrations.CreateLogins do
  use Ecto.Migration

  def change do
    create table(:logins, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :ip_address, :string, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:logins, [:user_id])
  end
end
