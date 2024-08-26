defmodule Fixxon.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE user_role AS ENUM ('user', 'admin')"
    drop_query = "DROP TYPE user_role"
    execute(create_query, drop_query)

    alter table("users") do
      add :role, :user_role
    end
  end
end
