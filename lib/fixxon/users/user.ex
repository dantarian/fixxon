defmodule Fixxon.Users.User do
  use Ecto.Schema

  use Pow.Ecto.Schema,
    user_id_field: :username

  import Pow.Ecto.Schema.Changeset,
    only: [new_password_changeset: 3, confirm_password_changeset: 3]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :role, Ecto.Enum, values: [:user, :admin], default: :user
    field :active, :boolean, default: true
    has_many(:logins, Fixxon.Users.Login)
    has_many(:batches, Fixxon.Production.Batch)

    pow_user_fields()

    timestamps()
  end

  @doc """
  Provides a changeset for changing a user's role.
  """
  @spec role_changeset(Ecto.Schema.t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def role_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, ~w(user admin)a)
  end

  @doc """
  Provides a changeset for changing a user's active state.
  """
  @spec active_changeset(Ecto.Schema.t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def active_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:active])
    |> Ecto.Changeset.validate_required(:active)
  end

  @doc """
  Provides a changeset for changing a user's password.
  """
  @spec password_changeset(Ecto.Schema.t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def password_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> new_password_changeset(attrs, @pow_config)
    |> Ecto.Changeset.validate_required([:password])
    |> confirm_password_changeset(attrs, @pow_config)
  end

  @doc """
  Provides a changeset for changing a user's basic details.
  """
  @spec update_changeset(Ecto.Schema.t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def update_changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_user_id_field_changeset(attrs)
  end

  @doc """
  Provides a changeset for deleting a user.
  """
  @spec delete_changeset(Ecto.Schema.t() | Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def delete_changeset(user_or_changeset) do
    user_or_changeset
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.no_assoc_constraint(:batches)
  end

  def validate_changed(cs, field) do
    if Map.has_key?(cs.changes, field) do
      cs
    else
      Ecto.Changeset.add_error(cs, field, "didn't change")
    end
  end
end
