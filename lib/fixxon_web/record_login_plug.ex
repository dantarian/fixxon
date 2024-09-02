defmodule FixxonWeb.RecordLoginPlug do
  alias Plug.Conn
  alias Pow.Plug

  def init(config), do: config

  def call(conn, _) do
    Conn.register_before_send(conn, fn conn ->
      user = Plug.current_user(conn)
      ip_address = conn.remote_ip |> :inet_parse.ntoa() |> to_string()

      unless is_nil(user), do: Fixxon.Users.record_login(user.id, ip_address)

      conn
    end)
  end
end
