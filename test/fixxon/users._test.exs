defmodule Fixxon.UsersTest do
  use Fixxon.DataCase

  alias Fixxon.{Repo, Users, Users.User}

  @valid_params %{username: "user1", password: "secret1234", password_confirmation: "secret1234"}

  test "create_admin/1" do
    assert {:ok, user} = Users.create_admin(@valid_params)
    assert user.role == :admin
  end

  test "set_admin_role/1" do
    assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
    assert user.role == :user

    assert {:ok, user} = Users.set_admin_role(user)
    assert user.role == :admin
  end

  test "is_admin?/1" do
    refute Users.is_admin?(nil)

    assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
    refute Users.is_admin?(user)

    assert {:ok, admin} = Users.create_admin(%{@valid_params | username: "admin_user"})
    assert Users.is_admin?(admin)
  end
end
