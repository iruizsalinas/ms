defmodule Ms.Parser do
  @moduledoc false

  alias Ms.{Decimal, Units}

  @max_input_bytes 100

  @spec parse(term()) :: integer() | :error
  def parse(input) when is_binary(input) and byte_size(input) <= @max_input_bytes do
    if String.valid?(input) do
      input
      |> String.trim()
      |> String.downcase()
      |> parse_signed()
    else
      :error
    end
  end

  def parse(_), do: :error

  defp parse_signed(<<"-", rest::binary>>), do: finish(rest, -1)
  defp parse_signed(<<"+", rest::binary>>), do: finish(rest, 1)
  defp parse_signed(rest), do: finish(rest, 1)

  defp finish(input, sign) do
    case segments(input, {0, 1}, 0) do
      {:ok, {number, scale}} -> Decimal.round(sign * number, scale)
      :error -> :error
    end
  end

  defp segments(input, total, count) do
    case skip_ws(input) do
      "" when count > 0 -> {:ok, total}
      "" -> :error
      rest -> segment(rest, total, count)
    end
  end

  defp segment(input, total, count) do
    with {:ok, number, rest} <- Decimal.parse(input) do
      {unit, rest} = rest |> skip_ws() |> take_unit(<<>>)
      accumulate(unit, rest, total, number, count)
    end
  end

  # Unitless values are allowed only as a standalone number.
  defp accumulate("", "", total, number, 0), do: {:ok, Decimal.add(total, number, 1)}
  defp accumulate("", _rest, _total, _number, _count), do: :error

  defp accumulate(unit, rest, total, number, count) do
    with {:ok, multiplier} <- Units.lookup(unit) do
      segments(rest, Decimal.add(total, number, multiplier), count + 1)
    end
  end

  defp take_unit(<<letter, rest::binary>>, unit) when letter in ?a..?z do
    take_unit(rest, <<unit::binary, letter>>)
  end

  defp take_unit(rest, unit), do: {unit, rest}

  defp skip_ws(<<char, rest::binary>>) when char in [?\s, ?\t], do: skip_ws(rest)
  defp skip_ws(rest), do: rest
end
