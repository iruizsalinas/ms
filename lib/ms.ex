defmodule Ms do
  @moduledoc """
  Tiny millisecond conversion utility.

  Converts duration strings to milliseconds:

      iex> Ms.parse("1h 30m")
      5400000

      iex> Ms.parse("1.5h")
      5400000

  Converts milliseconds to a readable string:

      iex> Ms.format(7200000)
      "2h"

      iex> Ms.format(7200000, long: true)
      "2 hours"

  | Unit | Short | Aliases |
  |------|-------|---------|
  | milliseconds | ms | ms, msec, msecs, millisecond(s) |
  | seconds | s | s, sec, secs, second(s) |
  | minutes | m | m, min, mins, minute(s) |
  | hours | h | h, hr, hrs, hour(s) |
  | days | d | d, day(s) |
  | weeks | w | w, wk, wks, week(s) |
  | months | mo | mo, month(s) |
  | years | y | y, yr, yrs, year(s) |

  A year is 365.25 days. A month is 30.4375 days, not a calendar month.
  """

  @doc """
  Parses a duration string into milliseconds. Returns `:error` for invalid input.

  Input must be valid UTF-8 and at most 100 bytes, including whitespace.
  Parsing is case-insensitive. A number on its own means milliseconds. When
  combining durations, each part needs a unit, as in `"1h 30m"`. Decimals can
  start with a dot (`".5s"`) but must have digits after it.

  A leading sign applies to the whole duration. The parts are added exactly,
  then the total is rounded to integer milliseconds. Halfway values round away
  from zero.

      iex> Ms.parse("100")
      100

      iex> Ms.parse("-1h 30m")
      -5400000

      iex> Ms.parse(".5ms .5ms")
      1

      iex> Ms.parse("1..2h")
      :error

      iex> Ms.parse("")
      :error
  """
  @spec parse(String.t()) :: integer() | :error
  defdelegate parse(input), to: Ms.Parser

  @doc """
  Parses a duration, raising `ArgumentError` on invalid input.

      iex> Ms.parse!("2h")
      7200000

      iex> Ms.parse!("500ms")
      500
  """
  @spec parse!(String.t()) :: integer()
  def parse!(input) do
    case parse(input) do
      :error -> raise ArgumentError, "invalid duration: #{inspect(input)}"
      ms -> ms
    end
  end

  @doc """
  Formats integer milliseconds using the largest suitable unit.

  Pass `long: true` to use full unit names. Values are rounded, so the output may
  not preserve the original duration. Halfway values round away from zero.

      iex> Ms.format(60000, long: true)
      "1 minute"

      iex> Ms.format(-1500)
      "-2s"

      iex> Ms.format(500)
      "500ms"

      iex> Ms.format(0)
      "0ms"
  """
  @spec format(integer(), keyword()) :: String.t()
  def format(ms, opts \\ []) when is_integer(ms) do
    Ms.Formatter.format(ms, Keyword.get(opts, :long, false))
  end
end
