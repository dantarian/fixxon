defmodule FixxonWeb.LoginHistoryController do
  use FixxonWeb, :controller

  def index(conn, _params) do
    logins = Fixxon.Users.list_logins()
    render(conn, :index, logins: logins, page_title: "Login History")
  end
end
