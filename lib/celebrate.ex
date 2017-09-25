defmodule Celebrate do
  use GenServer
  @moduledoc """
  Birthdays keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defstruct [ :type, :name, :date, :day, :month, :year ]

  # --------- GenServer Startup Functions

  @doc """
  Starts the GenServer.
  """
  def start_link do
    {:ok, _} = GenServer.start_link(__MODULE__, :ok, [name: CelebrateServer])
  end

  @doc """
  Read the rain data file and generate the list of rain gauge tips. This
  is held in the state as tips. tip_inches is amount of rain for each tip.
  """
  def init (:ok) do
    table = load_file()
    {:ok, table}
  end

  # --------- Client APIs

  @doc """
  Returns a list of birthday structures.
  """
  def get_celebrates do
    GenServer.call(CelebrateServer, :get_celebrates)
  end

  @doc """
  Returns a list of birthdays on the specified date and for the next n
  days.
  """
  def get_celebrates_in_window date, days do
    GenServer.call(CelebrateServer, :get_celebrates)
    |> Enum.filter(&(entry_in_window?(&1, date, days)))
  end

  # --------- GenServer Callbacks

    @doc """
    Returns list of birthday structures.
    """
    def handle_call(:get_celebrates, _from, state) do
      {:reply, state, state}
    end

  # ---------- Private Functions

  def entry_in_window? entry, date, days do
    nil !=
      date.year..date.year+1
      |> Enum.map(fn y -> Date.new(y, entry.month, entry.day) |> elem(1) end)
      |> Enum.find(&(date_in_window(&1, date, days)))
  end

  def date_in_window entry_date, date, days do
    diff = Date.diff(entry_date, date)
    diff < days && diff >= 0
  end

  def load_file do
    "/Users/bengm0ra/Projects/Filelif/Compendiums/Celebrate/celebrates"
    |> SprocksMapTable.read_file
    |> Enum.map(&create_structs/1)
    |> Enum.sort( fn(a,b) -> {a.month,a.day} <= {b.month,b.day} end )
#    |> IO.inspect
  end

  def create_structs record do
    { :ok, date } = SprocksMapTable.get_value(record, "date")
    { day, month, year } = parse_date date
    %Celebrate{
      type: elem(SprocksMapTable.get_value(record, "type"), 1),
      name: elem(SprocksMapTable.get_value(record, "name"), 1),
      date: date,
      day: day,
      month: month,
      year: year
    }
  end

  def parse_date date do
    parts = String.split(date,"-")
#    IO.inspect parts
    parts = set_date_parts parts
    parts
  end

  def set_date_parts [day, month_name] do
    { day, _ } = Integer.parse day
    month = month_name_to_number month_name
    { day, month, nil }
  end

  def set_date_parts [day, month_name, year] do
    { day, _ } = Integer.parse day
    { year, _ } = Integer.parse year
    month = month_name_to_number month_name
    { day, month, year }
  end

  def month_name_to_number month_name do
    [ part, _ ] = String.split("JanFebMarAprMayJunJulAugSepOctNovDec",month_name)
    length = String.length part
    length = div(length, 3) + 1
#    IO.inspect {:str, part1, length}
    length
  end
end
