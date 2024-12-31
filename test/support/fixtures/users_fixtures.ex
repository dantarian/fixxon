defmodule Fixxon.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fixxon.Users` context.
  """

  @doc """
  Generate a non-Admin user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        username: "user" <> Ecto.UUID.generate(),
        password: "password",
        password_confirmation: "password"
      })
      |> Fixxon.Users.create()

    user
  end

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

  def login_fixture(%{id: id}, ip \\ "192.168.0.1") do
    Fixxon.Users.record_login(id, ip)
  end
end
