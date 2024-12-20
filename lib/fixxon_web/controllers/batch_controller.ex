defmodule FixxonWeb.BatchController do
  use FixxonWeb, :controller

  alias Fixxon.Production
  alias Fixxon.Production.Batch

  def new(conn, _params) do
    changeset = Production.change_batch(%Batch{})
    batches = Production.list_today_batches_for_user(Pow.Plug.current_user(conn))
    render(conn, :new, changeset: changeset, batches: batches, page_title: "Log Work")
  end

  def create(conn, %{"batch" => batch_params}) do
    current_user = Pow.Plug.current_user(conn)

    case Production.create_batch(batch_params, current_user) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Batch created successfully.")
        |> redirect(to: ~p"/batches/new")

      {:error, %Ecto.Changeset{} = changeset} ->
        batches = Production.list_today_batches_for_user(current_user)
        render(conn, :new, changeset: changeset, batches: batches, page_title: "Log Work")
    end
  end

  def edit(conn, %{"id" => id}) do
    batch = Production.get_batch!(id)
    changeset = Production.change_batch(batch)
    render(conn, :edit, batch: batch, changeset: changeset)
  end

  def update(conn, %{"id" => id, "batch" => batch_params}) do
    batch = Production.get_batch!(id)

    case Production.update_batch(batch, batch_params) do
      {:ok, _batch} ->
        conn
        |> put_flash(:info, "Batch updated successfully.")
        |> redirect(to: ~p"/batches/new")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, batch: batch, changeset: changeset)
    end
  end
end
