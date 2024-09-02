defmodule FixxonWeb.BatchHTML do
  use FixxonWeb, :html

  embed_templates "batch_html/*"

  @doc """
  Renders a batch form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def batch_form(assigns)
end
