defmodule FixxonWeb.DashboardController do
  use FixxonWeb, :controller

  def index(conn, _params) do
    totals = Fixxon.Production.list_today_totals()

    render(conn, :index,
      totals: totals |> aggregate() |> Map.values() |> JsonSerde.serialize!(),
      page_title: "Dashboard"
    )
  end

  defp aggregate(data), do: do_aggregate(data, %{})

  defp do_aggregate([], result), do: result

  defp do_aggregate(
         [%{username: username, button_type: type, count: count} | rest],
         %{} = result
       ),
       do:
         do_aggregate(
           rest,
           result
           |> Map.update(
             username,
             %{"username" => username, Atom.to_string(type) => count, "total" => count},
             fn userdata ->
               userdata
               |> Map.put(Atom.to_string(type), count)
               |> Map.put("total", userdata["total"] + count)
             end
           )
         )
end
