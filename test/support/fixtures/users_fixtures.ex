defmodule Fixxon.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fixxon.Users` context.
  """

  @doc """
  Generate an Admin user.
  """
  def admin_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        username: "user" <> Ecto.UUID.generate(),
        password: "password",
        password_confirmation: "password"
      })
      |> Fixxon.Users.create_admin()

    user
  end
end
