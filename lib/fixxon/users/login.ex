defmodule Fixxon.Users.Login do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "logins" do
    field :ip_address, :string
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(login, attrs) do
    login
    |> cast(attrs, [:ip_address, :user_id])
    |> validate_required([:ip_address, :user_id])
  end
end
