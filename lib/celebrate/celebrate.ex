defmodule Celebrate.Server do
  use GenServer
  require Logger

  @moduledoc """
  Birthdays keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defstruct [:type, :name, :date, :day, :month, :year]

  # --------- GenServer Startup Functions

  @doc """
  Starts the GenServer.
  """
  def start_link(_args) do
    {:ok, _} = GenServer.start_link(__MODULE__, :ok, name: CelebrateServer)
  end

  @doc """
  Read the rain data file and generate the list of rain gauge tips. This
  is held in the state as tips. tip_inches is amount of rain for each tip.
  """
  def init(:ok) do
    {rev, _i} = System.cmd("git", ["rev-parse", "HEAD"])
    commit = rev |> String.slice(0..6)
    Logger.info("Commit: #{commit}")

    CelebrateStatus.start()
    table = load_file()
    {:ok, %{:table => table, :commit => commit}}
  end

  # --------- Client APIs

  def commit() do
    GenServer.call(CelebrateServer, :commit)
  end

  @doc """
  Returns a list of birthday structures.
  """
  def get_celebrates do
    GenServer.call(CelebrateServer, :get_celebrates)
  end

  def reload do
    GenServer.call(CelebrateServer, :reload)
  end

  @doc """
  Returns a list of birthdays on the specified date and for the next n
  days.
  """
  def get_celebrates_in_window(date, days) do
    GenServer.call(CelebrateServer, :get_celebrates)
    |> Enum.filter(fn e -> days_until(e, date) <= days end)
    |> Enum.sort_by(&days_until(&1, date))
  end

  def get_upcoming_celebrates(days) do
    {{year, month, day}, _time} = :calendar.local_time()
    {:ok, date} = Date.new(year, month, day)
    get_celebrates_in_window(date, days)
  end

  # --------- GenServer Callbacks

  def handle_call(:commit, _from, state) do
    {:reply, state.commit, state}
  end

  @doc """
  Returns list of birthday structures.
  """
  def handle_call(:get_celebrates, _from, state) do
    {:reply, state.table, state}
  end

  def handle_call(:reload, _from, state) do
    table = load_file()
    {:reply, :ok, %{state | table: table}}
  end

  # ---------- Private Functions

  # Returns the number of days from 'date' to the entry. Number will be
  # positive since time does not go backwards.
  def days_until(entry, date) do
    {:ok, entry_date} = Date.new(date.year, entry.month, entry.day)
    days = Date.diff(entry_date, date)

    cond do
      days >= 0 -> days
      true -> days + 365
    end
  end

  def load_file do
    Application.fetch_env!(:celebrate, :celebrates_file)
    |> SprocksMapTable.read_file()
    |> Enum.map(&create_structs/1)
    |> Enum.sort(fn a, b -> {a.month, a.day} <= {b.month, b.day} end)

    #    |> IO.inspect
  end

  def create_structs(record) do
    {:ok, date} = SprocksMapTable.get_value(record, "date")
    {day, month, year} = parse_date(date)

    %Celebrate.Server{
      type: elem(SprocksMapTable.get_value(record, "type"), 1),
      name: elem(SprocksMapTable.get_value(record, "name"), 1),
      date: date,
      day: day,
      month: month,
      year: year
    }
  end

  def parse_date(date) do
    parts = String.split(date, "-")
    #    IO.inspect parts
    parts = set_date_parts(parts)
    parts
  end

  def set_date_parts([day, month_name]) do
    {day, _} = Integer.parse(day)
    month = month_name_to_number(month_name)
    {day, month, nil}
  end

  def set_date_parts([day, month_name, year]) do
    {day, _} = Integer.parse(day)
    {year, _} = Integer.parse(year)
    month = month_name_to_number(month_name)
    {day, month, year}
  end

  def month_name_to_number(month_name) do
    [part, _] = String.split("JanFebMarAprMayJunJulAugSepOctNovDec", month_name)
    length = String.length(part)
    length = div(length, 3) + 1
    #    IO.inspect {:str, part1, length}
    length
  end
end
