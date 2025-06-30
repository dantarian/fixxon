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

  describe "active_changeset/2" do
    @active_user %User{username: "active_user", password_hash: "something", active: true}

    test "accepts no value, provided existing user has value set" do
      changeset = User.active_changeset(@active_user, %{})
      refute changeset.errors[:active]
    end

    test "accepts different value" do
      changeset = User.active_changeset(@active_user, %{active: false})
      refute changeset.errors[:active]
    end

    test "accepts same value" do
      changeset = User.active_changeset(@active_user, %{active: true})
      refute changeset.errors[:active]
    end
  end

  describe "password_changeset/2" do
    @existing_user %User{username: "user", password_hash: "something"}

    test "accepts updated password" do
      changeset =
        User.password_changeset(@existing_user, %{
          password: "secret123",
          password_confirmation: "secret123"
        })

      refute changeset.errors[:password]
      refute changeset.errors[:password_confirmation]
    end

    test "rejects missing password" do
      changeset =
        User.password_changeset(@existing_user, %{
          password_confirmation: "secret123"
        })

      assert {"can't be blank", [validation: :required]} = changeset.errors[:password]
    end

    test "rejects mismatched password confirmation" do
      changeset =
        User.password_changeset(@existing_user, %{
          password: "secret123",
          password_confirmation: "othersecret"
        })

      assert {"does not match confirmation", [validation: :confirmation]} =
               changeset.errors[:password_confirmation]
    end

    test "rejects missing password confirmation" do
      changeset =
        User.password_changeset(@existing_user, %{
          password: "secret123"
        })

      assert {"can't be blank", [validation: :required]} =
               changeset.errors[:password_confirmation]
    end
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
  end

  describe "delete_changeset/1" do
    @existing_user %User{username: "user", password_hash: "something"}

    test "adds constraint" do
      changeset = User.delete_changeset(@existing_user)
      assert length(changeset.constraints) > 0
    end
  end
end
