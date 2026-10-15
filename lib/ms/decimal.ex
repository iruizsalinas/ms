defmodule Ms.Decimal do
  @moduledoc false

  @type t :: {non_neg_integer(), pos_integer()}

  @spec parse(binary()) :: {:ok, t(), binary()} | :error
  def parse(input) do
    {integer, count, rest} = digits(input, 0, 0)

    case rest do
      <<".", fractional::binary>> -> fraction(integer, fractional)
      _ when count > 0 -> {:ok, {integer, 1}, rest}
      _ -> :error
    end
  end

  defp fraction(integer, input) do
    case digits(input, 0, 0) do
      {_, 0, _} ->
        :error

      {fraction, count, rest} ->
        scale = Integer.pow(10, count)
        {:ok, {integer * scale + fraction, scale}, rest}
    end
  end

  defp digits(<<digit, rest::binary>>, value, count) when digit in ?0..?9 do
    digits(rest, value * 10 + digit - ?0, count + 1)
  end

  defp digits(rest, value, count), do: {value, count, rest}

  # All denominators are powers of ten, so the larger is a common denominator.
  @spec add(t(), t(), pos_integer()) :: t()
  def add({total, total_scale}, {number, scale}, multiplier) do
    common = max(total_scale, scale)
    {total * div(common, total_scale) + number * multiplier * div(common, scale), common}
  end

  @spec round(integer(), pos_integer()) :: integer()
  def round(numerator, denominator) do
    magnitude = div(abs(numerator), denominator)
    rounded = magnitude + if(2 * rem(abs(numerator), denominator) >= denominator, do: 1, else: 0)
    if numerator < 0, do: -rounded, else: rounded
  end
end
