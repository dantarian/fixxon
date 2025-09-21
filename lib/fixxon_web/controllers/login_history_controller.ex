defmodule FixxonWeb.LoginHistoryController do
  use FixxonWeb, :controller

  def index(conn, params) do
    {logins, meta} = Fixxon.Users.list_logins(params)
    render(conn, :index, logins: logins, meta: meta, page_title: "Login History")
  end
end
