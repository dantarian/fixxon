defmodule FixxonWeb.DashboardController do
  use FixxonWeb, :controller

  def index(conn, _params) do
    totals = Fixxon.Production.list_today_totals()
    render(conn, :index, totals: totals)
  end
end
