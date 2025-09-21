defmodule Fixxon.Users do
  alias Fixxon.{Repo, Users.User, Users.Login, Production.Batch}
  import Ecto.Query, warn: false

  @type t :: %User{}
  @type login :: %Login{}

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes (creation only).

  ## Examples

      iex> change_user_for_create(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_for_create(user = %User{}, params \\ %{}), do: User.changeset(user, params)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes (update only).

  ## Examples

      iex> change_user_for_update(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_for_update(user = %User{}, params \\ %{}),
    do: User.update_changeset(user, params)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user password changes.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user = %User{}, params \\ %{}),
    do: User.password_changeset(user, params)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user role changes.

  ## Examples

    iex> change_user_role(user)
    %Ecto.Changeset{data: %User{}}

  """
  def change_user_role(user = %User{}, params \\ %{}), do: User.role_changeset(user, params)

  @doc """
  Gets a list of users in alphabetical order of username.
  """
  @spec list_users() :: [t()]
  def list_users() do
    Repo.all(
      from u in User,
        as: :user,
        order_by: u.username,
        left_join: b in Batch,
        on: b.user_id == u.id,
        group_by: u.id,
        select: %{
          u
          | metadata: %User.Metadata{
              has_batches:
                exists(
                  from b in Batch,
                    where: b.user_id == parent_as(:user).id,
                    limit: 1,
                    select: 1
                )
            }
        }
    )
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(Ecto.UUID.generate())
      %User{}

      iex> get_user!(Ecto.UUID.generate())
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @doc """
  Creates a non-admin user.
  """
  @spec create(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  @doc """
  Creates an admin user.
  """
  @spec create_admin(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create_admin(params) do
    %User{}
    |> User.changeset(params)
    |> User.role_changeset(%{role: :admin})
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update(user, %{username: new_value})
      {:ok, %User{}}

      iex> update(user, %{username: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's password.

  ## Examples

      iex> update_password(user, %{password: "new_value", confirm_password: "new_value"})
      {:ok, %User{}}

      iex> update_password(user, %{password: "new_value"})
      {:error, %Ecto.Changeset{}}

      iex> update_password(user, %{password: "new_value", confirm_password: "different"})
      {:error, %Ecto.Changeset{}}

  """
  def update_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Turns a non-admin user into an admin user.
  """
  @spec set_admin_role(t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def set_admin_role(user) do
    user
    |> User.role_changeset(%{role: :admin})
    |> Repo.update()
  end

  @doc """
  Turns an admin user into a non-admin user.
  """
  @spec set_user_role(t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def set_user_role(user) do
    user
    |> User.role_changeset(%{role: :user})
    |> Repo.update()
  end

  @doc """
  Checks whether the supplied user is an admin.
  """
  @spec is_admin?(t()) :: boolean()
  def is_admin?(%{role: :admin}), do: true
  def is_admin?(_), do: false

  @doc """
  Deactivates a user, preventing them from being able to log in.
  """
  @spec deactivate_user(t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def deactivate_user(user), do: user |> User.active_changeset(%{active: false}) |> Repo.update()

  @doc """
  Reactivates a user, allowing them to log in.
  """
  @spec activate_user(t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def activate_user(user), do: user |> User.active_changeset(%{active: true}) |> Repo.update()

  @doc """
  Deletes the supplied user.
  """
  @spec delete_user(t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def delete_user(%User{} = user), do: user |> User.delete_changeset() |> Repo.delete()

  @doc """
  Creates a login record for the specified user.
  """
  @spec record_login(Ecto.UUID.t(), String.t()) :: {:ok, login()} | {:error, Ecto.Changeset.t()}
  def record_login(user_id, ip_address) do
    %Login{}
    |> Login.changeset(%{user_id: user_id, ip_address: ip_address})
    |> Repo.insert()
  end

  @doc """
  Returns a list of user logins.
  """
  @spec list_logins(map) :: {:ok, {[login()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def list_logins(params \\ %{}) do
    opts = [for: Login, replace_invalid_params: true, default_pagination_type: :first]

    with {:ok, flop} <- Flop.validate(params, opts) do
      Login
      |> Flop.with_named_bindings(flop, &join_login_assocs/2, opts)
      |> Flop.run(flop, opts)
    end
  end

  defp join_login_assocs(query, :user) do
    query
    |> join(:inner, [l], u in assoc(l, :user), as: :user)
    |> preload([user: u], user: u)
  end
end
