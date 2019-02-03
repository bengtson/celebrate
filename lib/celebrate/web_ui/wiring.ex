defmodule Wiring do
  require EEx

  # Main Web Page Code --------------------------

  EEx.function_from_file(:def, :main_list, "lib/celebrate/web_ui/templates/main.html.eex")

  EEx.function_from_file(
    :def,
    :celebrate_entry,
    "lib/celebrate/web_ui/templates/celebrate_entry.html.eex",
    [:month, :day, :year, :type, :name, :age, :days]
  )

  def main do
    {:safe, main_list()}
  end

  def get_upcoming_list do
    Celebrate.Server.get_upcoming_celebrates(21)
    #    |> Enum.map(&entry(&1,get_age(&1,&1.year)))
    |> Enum.map(&write_entry/1)
  end

  def write_entry(entry) do
    {age, days} = get_celebrate_age(entry, entry.year)
    month = get_short_month_name(entry.month)
    celebrate_entry(month, entry.day, entry.year, entry.type, entry.name, age, days)
    #    [entry, age, days]
  end

  def get_celebrate_age(entry, year) do
    month = entry.month
    day = entry.day
    {{y, m, d}, _t} = :calendar.local_time()
    {:ok, today} = Date.new(y, m, d)

    days_in_year =
      case Date.leap_year?(today) do
        true -> 366
        false -> 365
      end

    {:ok, date_in_year} = Date.new(y, month, day)
    days = Date.diff(date_in_year, today)

    cond do
      year == nil && days >= 0 ->
        {"", "#{days}"}

      year == nil ->
        {"", "#{days + days_in_year}"}

      days >= 0 ->
        {"#{y - year}", "#{days}"}

      true ->
        {"#{y - year + 1}", "#{days + days_in_year}"}
    end
  end

  # Main Web Page Code --------------------------

  # All Web Page Code --------------------------

  EEx.function_from_file(:def, :show_all, "lib/celebrate/web_ui/templates/show_all.html.eex")

  EEx.function_from_file(:def, :entry, "lib/celebrate/web_ui/templates/entry.html.eex", [
    :month,
    :day,
    :year,
    :type,
    :name,
    :age
  ])

  def all do
    {:safe, show_all()}
  end

  def get_list do
    Celebrate.Server.get_celebrates()
    #    |> Enum.map(&entry(&1,get_age(&1,&1.year)))
    |> Enum.map(&write_all_entry/1)
  end

  def write_all_entry(c) do
    month = get_short_month_name(c.month)
    entry(month, c.day, c.year, c.type, c.name, get_age_today(c, c.year))
  end

  def get_age_today(c, nil), do: ""

  def get_age_today(c, _) do
    {{y, m, d}, _t} = :calendar.local_time()
    {:ok, today} = Date.new(y, m, d)
    {:ok, date} = Date.new(y, c.month, c.day)
    days = Date.diff(date, today)

    cond do
      days > 0 ->
        "#{y - c.year - 1}"

      true ->
        "#{y - c.year}"
    end
  end

  def get_short_month_name(month_number) do
    index = (month_number - 1) * 3
    range = index..(index + 2)
    String.slice("JanFebMarAprMayJunJulAugSepOctNovDec", range)
  end

  # All Web Page Code --------------------------
end
