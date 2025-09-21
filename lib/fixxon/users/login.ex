defmodule Fixxon.Users.Login do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:username, :inserted_at],
    sortable: [:username, :inserted_at],
    adapter_opts: [
      join_fields: [
        username: [
          binding: :user,
          field: :username,
          ecto_type: :string
        ]
      ]
    ],
    max_limit: 10,
    default_limit: 10,
    default_order: %{
      order_by: [:inserted_at, :username],
      order_directions: [:desc, :asc]
    },
    pagination_types: [:first, :last]
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "logins" do
    field :ip_address, :string

    belongs_to :user, Fixxon.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(login, attrs) do
    login
    |> cast(attrs, [:ip_address, :user_id])
    |> validate_required([:ip_address, :user_id])
  end
end
