defmodule FixxonWeb.RateLimitLoginPlug do
  alias Plug.Conn

  def init(config), do: config

  def call(conn, _) do
    ip_address = conn.remote_ip |> :inet_parse.ntoa() |> to_string()
    key = "login:#{ip_address}"
    scale = :timer.minutes(1)
    limit = 10

    case Fixxon.RateLimit.hit(key, scale, limit) do
      {:allow, _count} ->
        conn

      {:deny, retry_after} ->
        conn
        |> Conn.put_resp_header("retry-after", Integer.to_string(div(retry_after, 1000)))
        |> Conn.send_resp(429, [])
        |> Conn.halt()
    end
  end
end
