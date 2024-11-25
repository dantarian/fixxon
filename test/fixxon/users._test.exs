defmodule Fixxon.UsersTest do
  use Fixxon.DataCase

  alias Fixxon.{Repo, Users, Users.User}

  @valid_params %{username: "user1", password: "secret1234", password_confirmation: "secret1234"}

  test "create_admin/1" do
    assert {:ok, user} = Users.create_admin(@valid_params)
    assert user.role == :admin
  end

  test "set_admin_role/1 and set_user_role/1" do
    assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
    assert user.role == :user

    assert {:ok, user} = Users.set_admin_role(user)
    assert user.role == :admin

    assert {:ok, user} = Users.set_user_role(user)
    assert user.role == :user
  end

  test "is_admin?/1" do
    refute Users.is_admin?(nil)

    assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
    refute Users.is_admin?(user)

    assert {:ok, admin} = Users.create_admin(%{@valid_params | username: "admin_user"})
    assert Users.is_admin?(admin)
  end

  test "record_login/2 and list_logins/0" do
    assert {:ok, %{id: id, username: username}} =
             Repo.insert(User.changeset(%User{}, @valid_params))

    assert {:ok, _login} = Users.record_login(id, "192.168.0.1")

    assert match?(
             [%{inserted_at: _, username: ^username, ip_address: "192.168.0.1"}],
             Users.list_logins()
           )
  end
end
