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

  test "role_changeset/2" do
    changeset = User.role_changeset(%User{}, %{role: "invalid"})

    assert {"is invalid", [type: _, validation: :inclusion, enum: ["admin", "user"]]} =
             changeset.errors[:role]

    changeset = User.role_changeset(%User{}, %{role: :admin})
    refute changeset.errors[:role]
  end

  describe "update_changeset/2" do
    @existing_user %User{username: "user", password_hash: "something"}

    test "accepts empty changeset" do
      changeset = User.update_changeset(@existing_user, %{})
      assert changeset.errors == []
    end

    test "accepts updated name" do
      changeset = User.update_changeset(@existing_user, %{username: "new name"})
      refute changeset.errors[:username]
    end

    test "accepts updated password" do
      changeset =
        User.update_changeset(@existing_user, %{
          password: "secret123",
          password_confirmation: "secret123"
        })

      refute changeset.errors[:password]
      refute changeset.errors[:password_confirmation]
    end

    test "rejects mismatched password confirmation" do
      changeset =
        User.update_changeset(@existing_user, %{
          password: "secret123",
          password_confirmation: "othersecret"
        })

      assert {"does not match confirmation", [validation: :confirmation]} =
               changeset.errors[:password_confirmation]
    end

    test "rejects missing password confirmation" do
      changeset =
        User.update_changeset(@existing_user, %{
          password: "secret123"
        })

      assert {"can't be blank", [validation: :required]} =
               changeset.errors[:password_confirmation]
    end
  end
end
