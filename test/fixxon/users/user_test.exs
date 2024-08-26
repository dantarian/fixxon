defmodule Fixxon.Users.UserTest do
  use Fixxon.DataCase

  alias Fixxon.Users.User

  test "changeset/2 sets default role" do
    user =
      %User{}
      |> User.changeset(%{})
      |> Ecto.Changeset.apply_changes()

    assert user.role == :user
  end

  test "changeset_role/2" do
    changeset = User.changeset_role(%User{}, %{role: "invalid"})

    assert {"is invalid", [type: _, validation: :inclusion, enum: ["admin", "user"]]} =
             changeset.errors[:role]

    changeset = User.changeset_role(%User{}, %{role: :admin})
    refute changeset.errors[:role]
  end
end
