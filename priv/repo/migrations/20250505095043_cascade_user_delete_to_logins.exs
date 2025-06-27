defmodule Fixxon.Repo.Migrations.CascadeUserDeleteToLogins do
  use Ecto.Migration

  def change do
    alter table("logins") do
      modify :user_id, references(:users, on_delete: :delete_all, type: :binary_id),
        null: false,
        from: references(:users, on_delete: :nothing, type: :binary_id)
    end
  end
end
