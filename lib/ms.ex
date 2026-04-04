defmodule Ms do
  @moduledoc """
  Tiny millisecond conversion utility

  ## Parsing

  Converts a human-readable duration string into milliseconds:

      iex> Ms.parse("2h")
      7200000

      iex> Ms.parse("1.5h")
      5400000

  Supports compound durations:

      iex> Ms.parse("1h 30m")
      5400000

  ## Formatting

  Converts milliseconds into a human-readable string:

      iex> Ms.format(7200000)
      "2h"

      iex> Ms.format(7200000, long: true)
      "2 hours"

  ## Supported units

  | Unit         | Short | Aliases                            |
  |--------------|-------|------------------------------------|
  | milliseconds | ms    | ms, msec, msecs, millisecond(s)    |
  | seconds      | s     | s, sec, secs, second(s)            |
  | minutes      | m     | m, min, mins, minute(s)            |
  | hours        | h     | h, hr, hrs, hour(s)                |
  | days         | d     | d, day(s)                          |
  | weeks        | w     | w, wk, wks, week(s)               |
  | months       | mo    | mo, month(s)                       |
  | years        | y     | y, yr, yrs, year(s)                |

  A year is defined as 365.25 days.
  """

  @millisecond 1
  @second 1_000
  @minute 60 * @second
  @hour 60 * @minute
  @day 24 * @hour
  @week 7 * @day
  @year round(365.25 * @day)
  @month div(@year, 12)

  @max_input_length 100

  @doc """
  Parses a duration string into milliseconds.

  Returns the value in milliseconds, or `:error` on invalid input.
  Parsing is case-insensitive. A bare number with no unit is treated as
  milliseconds. Compound durations like `"1h 30m"` are supported.

  ## Examples

      iex> Ms.parse("2h")
      7200000

      iex> Ms.parse("1.5h")
      5400000

      iex> Ms.parse("1h 30m")
      5400000

      iex> Ms.parse("100")
      100

      iex> Ms.parse("-3d")
      -259200000

      iex> Ms.parse("1 second")
      1000

      iex> Ms.parse("")
      :error

  """
  @spec parse(String.t()) :: integer() | :error
  def parse(input) when is_binary(input) do
    trimmed = String.trim(input)

    cond do
      trimmed == "" ->
        :error

      byte_size(trimmed) > @max_input_length ->
        :error

      true ->
        downcased = String.downcase(trimmed)
        {negative?, rest} = parse_sign(downcased)

        case parse_segments(rest, 0, 0) do
          {:ok, total} -> if(negative?, do: -total, else: total)
          :error -> :error
        end
    end
  end

  def parse(_), do: :error

  @doc """
  Parses a duration string into milliseconds, raising on invalid input.

  ## Examples

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
  Formats milliseconds into a human-readable duration string.

  Pass `long: true` for verbose output. The formatter picks the single
  largest appropriate unit and rounds the value.

  ## Examples

      iex> Ms.format(7200000)
      "2h"

      iex> Ms.format(60000, long: true)
      "1 minute"

      iex> Ms.format(7200000, long: true)
      "2 hours"

      iex> Ms.format(-3600000)
      "-1h"

      iex> Ms.format(500)
      "500ms"

      iex> Ms.format(0)
      "0ms"

  """
  @spec format(integer(), keyword()) :: String.t()
  def format(ms, opts \\ []) when is_integer(ms) do
    do_format(ms, Keyword.get(opts, :long, false))
  end

  defp parse_sign(<<"-", rest::binary>>), do: {true, rest}
  defp parse_sign(<<"+", rest::binary>>), do: {false, rest}
  defp parse_sign(rest), do: {false, rest}

  defp parse_segments(<<>>, total, n) when n > 0, do: {:ok, total}
  defp parse_segments(<<>>, _total, 0), do: :error

  defp parse_segments(input, total, n) do
    input = skip_ws(input)

    case input do
      <<>> when n > 0 -> {:ok, total}
      <<>> -> :error
      _ -> parse_one_segment(input, total, n)
    end
  end

  defp parse_one_segment(input, total, n) do
    with {:ok, number, rest} <- parse_number(input),
         rest = skip_ws(rest),
         {:ok, multiplier, rest} <- parse_unit(rest) do
      parse_segments(rest, total + round(number * multiplier), n + 1)
    else
      _ -> :error
    end
  end

  defp parse_number(input) do
    {int_digits, rest} = take_digits(input)

    case rest do
      <<".", rest2::binary>> ->
        {frac_digits, rest3} = take_digits(rest2)
        build_float(int_digits, frac_digits, rest3)

      _ when int_digits != "" ->
        {:ok, String.to_integer(int_digits), rest}

      _ ->
        :error
    end
  end

  defp build_float(int_digits, frac_digits, rest)
       when int_digits != "" or frac_digits != "" do
    int_str = if int_digits == "", do: "0", else: int_digits
    frac_str = if frac_digits == "", do: "0", else: frac_digits
    {:ok, String.to_float("#{int_str}.#{frac_str}"), rest}
  end

  defp build_float(_int_digits, _frac_digits, _rest), do: :error

  defp take_digits(<<c, rest::binary>>) when c in ?0..?9 do
    {more, rest2} = take_digits(rest)
    {<<c, more::binary>>, rest2}
  end

  defp take_digits(rest), do: {"", rest}

  defp parse_unit(input) do
    {unit_str, rest} = take_alpha(input)

    case unit_str do
      "" -> {:ok, @millisecond, rest}
      _ -> lookup_unit(unit_str, rest)
    end
  end

  defp lookup_unit(unit_str, rest) do
    case unit_to_ms(unit_str) do
      {:ok, ms} -> {:ok, ms, rest}
      :error -> :error
    end
  end

  defp take_alpha(<<c, rest::binary>>) when c in ?a..?z do
    {more, rest2} = take_alpha(rest)
    {<<c, more::binary>>, rest2}
  end

  defp take_alpha(rest), do: {"", rest}

  defp skip_ws(<<c, rest::binary>>) when c in [?\s, ?\t], do: skip_ws(rest)
  defp skip_ws(rest), do: rest

  defp unit_to_ms("ms"), do: {:ok, @millisecond}
  defp unit_to_ms("msec"), do: {:ok, @millisecond}
  defp unit_to_ms("msecs"), do: {:ok, @millisecond}
  defp unit_to_ms("millisecond"), do: {:ok, @millisecond}
  defp unit_to_ms("milliseconds"), do: {:ok, @millisecond}

  defp unit_to_ms("s"), do: {:ok, @second}
  defp unit_to_ms("sec"), do: {:ok, @second}
  defp unit_to_ms("secs"), do: {:ok, @second}
  defp unit_to_ms("second"), do: {:ok, @second}
  defp unit_to_ms("seconds"), do: {:ok, @second}

  defp unit_to_ms("m"), do: {:ok, @minute}
  defp unit_to_ms("min"), do: {:ok, @minute}
  defp unit_to_ms("mins"), do: {:ok, @minute}
  defp unit_to_ms("minute"), do: {:ok, @minute}
  defp unit_to_ms("minutes"), do: {:ok, @minute}

  defp unit_to_ms("h"), do: {:ok, @hour}
  defp unit_to_ms("hr"), do: {:ok, @hour}
  defp unit_to_ms("hrs"), do: {:ok, @hour}
  defp unit_to_ms("hour"), do: {:ok, @hour}
  defp unit_to_ms("hours"), do: {:ok, @hour}

  defp unit_to_ms("d"), do: {:ok, @day}
  defp unit_to_ms("day"), do: {:ok, @day}
  defp unit_to_ms("days"), do: {:ok, @day}

  defp unit_to_ms("w"), do: {:ok, @week}
  defp unit_to_ms("wk"), do: {:ok, @week}
  defp unit_to_ms("wks"), do: {:ok, @week}
  defp unit_to_ms("week"), do: {:ok, @week}
  defp unit_to_ms("weeks"), do: {:ok, @week}

  defp unit_to_ms("mo"), do: {:ok, @month}
  defp unit_to_ms("month"), do: {:ok, @month}
  defp unit_to_ms("months"), do: {:ok, @month}

  defp unit_to_ms("y"), do: {:ok, @year}
  defp unit_to_ms("yr"), do: {:ok, @year}
  defp unit_to_ms("yrs"), do: {:ok, @year}
  defp unit_to_ms("year"), do: {:ok, @year}
  defp unit_to_ms("years"), do: {:ok, @year}

  defp unit_to_ms(_), do: :error

  defp do_format(ms, long?) do
    abs_ms = abs(ms)

    cond do
      abs_ms >= @year -> format_unit(ms, abs_ms, @year, "y", "year", long?)
      abs_ms >= @month -> format_unit(ms, abs_ms, @month, "mo", "month", long?)
      abs_ms >= @week -> format_unit(ms, abs_ms, @week, "w", "week", long?)
      abs_ms >= @day -> format_unit(ms, abs_ms, @day, "d", "day", long?)
      abs_ms >= @hour -> format_unit(ms, abs_ms, @hour, "h", "hour", long?)
      abs_ms >= @minute -> format_unit(ms, abs_ms, @minute, "m", "minute", long?)
      abs_ms >= @second -> format_unit(ms, abs_ms, @second, "s", "second", long?)
      long? -> "#{ms} ms"
      true -> "#{ms}ms"
    end
  end

  defp format_unit(ms, abs_ms, unit_ms, short, long_name, long?) do
    rounded = round(ms / unit_ms)

    if long? do
      suffix = if abs_ms >= unit_ms * 1.5, do: "s", else: ""
      "#{rounded} #{long_name}#{suffix}"
    else
      "#{rounded}#{short}"
    end
  end
end
