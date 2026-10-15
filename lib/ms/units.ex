defmodule Ms.Units do
  @moduledoc false

  @second 1_000
  @minute 60 * @second
  @hour 60 * @minute
  @day 24 * @hour
  @week 7 * @day
  @year div(1461 * @day, 4)
  @month div(@year, 12)

  # Descending order is also the formatter's unit preference.
  @units [
    {@year, "y", "year", ~w(y yr yrs year years)},
    {@month, "mo", "month", ~w(mo month months)},
    {@week, "w", "week", ~w(w wk wks week weeks)},
    {@day, "d", "day", ~w(d day days)},
    {@hour, "h", "hour", ~w(h hr hrs hour hours)},
    {@minute, "m", "minute", ~w(m min mins minute minutes)},
    {@second, "s", "second", ~w(s sec secs second seconds)},
    {1, "ms", "millisecond", ~w(ms msec msecs millisecond milliseconds)}
  ]
  @lookup for {multiplier, _, _, aliases} <- @units,
              name <- aliases,
              into: %{},
              do: {name, multiplier}
  @format_units for {multiplier, short, name, _} <- @units, do: {multiplier, short, name}

  @spec lookup(String.t()) :: {:ok, pos_integer()} | :error
  def lookup(name), do: Map.fetch(@lookup, name)

  @spec formatting() :: [{pos_integer(), String.t(), String.t()}]
  def formatting, do: @format_units
end
