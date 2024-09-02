defmodule FixxonWeb.Time do
  use FixxonWeb, :html

  attr :formatted_datetime, :string, default: nil
  attr :datetime, DateTime
  attr :format, :atom, default: :full

  def formatted_time(%{formatted_datetime: formatted_datetime} = assigns)
      when not is_nil(formatted_datetime) do
    ~H"<%= @formatted_datetime %>"
  end

  def formatted_time(%{datetime: datetime, format: format} = assigns) do
    server_tz = Application.fetch_env!(:fixxon, :server_tz)
    display_tz = Application.fetch_env!(:fixxon, :display_tz)

    format_string =
      case format do
        :time -> "%H:%M:%S"
        _ -> "%d/%m/%Y %H:%M:%S"
      end

    output =
      DateTime.new!(DateTime.to_date(datetime), DateTime.to_time(datetime), server_tz)
      |> DateTime.shift_zone!(display_tz)
      |> Calendar.Strftime.strftime!(format_string)

    assigns
    |> assign(:formatted_datetime, output)
    |> formatted_time()
  end
end
