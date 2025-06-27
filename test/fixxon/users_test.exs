defmodule Fixxon.UsersTest do
  use Fixxon.DataCase

  alias Fixxon.{Repo, Users, Users.User, UsersFixtures, ProductionFixtures}

  @valid_params %{username: "user1", password: "secret1234", password_confirmation: "secret1234"}
  @valid_update_params %{
    username: "updated user"
  }
  @valid_password_update_params %{
    password: "newsecret1",
    password_confirmation: "newsecret1"
  }

  describe "list_users/0" do
    test "with no data" do
      assert [] = Users.list_users()
    end

    test "with data" do
      user = UsersFixtures.user_fixture()
      assert [^user] = Users.list_users()
    end

    test "results come back in alphabetical order of username" do
      user1 = UsersFixtures.user_fixture(%{username: "zorro"})
      user2 = UsersFixtures.user_fixture(%{username: "nobody"})
      user3 = UsersFixtures.user_fixture(%{username: "alan"})
      assert [^user3, ^user2, ^user1] = Users.list_users()
    end
  end

  describe "create/1" do
    test "with valid parameters" do
      assert {:ok, user} = Users.create(@valid_params)
      assert user.role == :user
    end

    test "with invalid password" do
      assert {:error, _} =
               Users.create(%{
                 username: "user1",
                 password: "2short",
                 password_confirmation: "2short"
               })
    end

    test "with non-matching password" do
      assert {:error, _} =
               Users.create(%{
                 username: "user1",
                 password: "secret1234",
                 password_confirmation: "secret123"
               })
    end
  end

  test "create_admin/1" do
    assert {:ok, user} = Users.create_admin(@valid_params)
    assert user.role == :admin
  end

  describe "get_user!/1" do
    setup [:create_user]

    test "with valid id", %{user: user} do
      assert ^user = Users.get_user!(user.id)
    end

    test "with unknown id" do
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(Ecto.UUID.generate()) end
    end
  end

  describe "update/2" do
    setup [:create_user]

    test "with valid parameters", %{user: user} do
      assert {:ok, user} = Users.update(user, @valid_update_params)
      assert user.username == "updated user"
    end
  end

  describe "update_password/2" do
    setup [:create_user]

    test "with valid parameters", %{user: user} do
      assert {:ok, updated_user} = Users.update_password(user, @valid_password_update_params)
      assert user.password_hash != updated_user.password_hash
    end

    test "with invalid password", %{user: user} do
      assert {:error, _} =
               Users.update_password(user, %{
                 password: "2short",
                 password_confirmation: "2short"
               })
    end

    test "with non-matching password", %{user: user} do
      assert {:error, _} =
               Users.update_password(user, %{
                 password: "secret1234",
                 password_confirmation: "secret123"
               })
    end

    test "without changing password", %{user: user} do
      assert {:error, _} = Users.update_password(user, %{})
    end
  end

  describe "delete_user/1" do
    setup [:create_user]

    test "user is deleted", %{user: user} do
      assert {:ok, _} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "user with logins is deleted", %{user: user} do
      assert {:ok, _login} = Users.record_login(user.id, "192.168.0.1")
      assert {:ok, _} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "user with batches is not deleted", %{user: user} do
      ProductionFixtures.batch_fixture(user)
      assert {:error, _} = Users.delete_user(user)
    end
  end

  test "set_admin_role/1 and set_user_role/1" do
    assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
    assert user.role == :user

    assert {:ok, user} = Users.set_admin_role(user)
    assert user.role == :admin

    assert {:ok, user} = Users.set_user_role(user)
    assert user.role == :user
  end

  test "activate_user/1 and deactivate_user/1" do
    assert {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_params))
    assert user.active

    assert {:ok, user} = Users.deactivate_user(user)
    refute user.active

    assert {:ok, user} = Users.activate_user(user)
    assert user.active
  end

  test "is_admin?/1" do
    refute Users.is_admin?(nil)

    assert {:ok, user} = Users.create(@valid_params)
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

  defp create_user(_) do
    user = UsersFixtures.user_fixture()
    %{user: user}
  end
end
