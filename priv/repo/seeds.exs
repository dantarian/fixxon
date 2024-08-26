# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fixxon.Repo.insert!(%Fixxon.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Fixxon.Users.create_admin(%{
  username: System.get_env("ADMIN_USERNAME", "admin"),
  password: System.get_env("ADMIN_PASSWORD"),
  password_confirmation: System.get_env("ADMIN_PASSWORD")
})
