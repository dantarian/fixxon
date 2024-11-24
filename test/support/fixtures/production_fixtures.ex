defmodule Fixxon.ProductionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fixxon.Production` context.
  """

  @doc """
  Generate a batch.
  """
  def batch_fixture(user = %Fixxon.Users.User{}, attrs \\ %{}) do
    {:ok, batch} =
      attrs
      |> Enum.into(%{
        count: 42,
        order_number: "some order_number",
        button_type: :names,
        batch_type: :order
      })
      |> Fixxon.Production.create_batch(user)

    batch
  end

  @doc """
  Generate a batch from yesterday.
  """
  def old_batch_fixture(user = %Fixxon.Users.User{}, attrs \\ %{}) do
    batch =
      attrs
      |> Enum.into(%{
        count: 42,
        order_number: "some order_number",
        button_type: :names,
        batch_type: :order,
        user_id: user.id,
        inserted_at: DateTime.utc_now() |> DateTime.add(-1, :day) |> DateTime.truncate(:second)
      })

    {:ok, batch} = struct(Fixxon.Production.Batch, batch) |> Fixxon.Repo.insert()

    batch
  end
end
