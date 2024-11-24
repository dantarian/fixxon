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
        stock: true,
        button_type: :names,
        batch_type: :order
      })
      |> Fixxon.Production.create_batch(user)

    batch
  end
end
