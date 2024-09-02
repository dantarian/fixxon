defmodule Fixxon.ProductionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fixxon.Production` context.
  """

  @doc """
  Generate a batch.
  """
  def batch_fixture(attrs \\ %{}) do
    {:ok, batch} =
      attrs
      |> Enum.into(%{
        count: 42,
        order_number: "some order_number",
        stock: true,
        type: :names
      })
      |> Fixxon.Production.create_batch()

    batch
  end
end
