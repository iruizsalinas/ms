defmodule Ms.Formatter do
  @moduledoc false

  alias Ms.{Decimal, Units}

  @spec format(integer(), term()) :: String.t()
  def format(ms, long?) do
    {unit, short, name} =
      Enum.find(Units.formatting(), fn {unit, _, _} -> abs(ms) >= unit or unit == 1 end)

    rounded = Decimal.round(ms, unit)

    cond do
      !long? -> "#{rounded}#{short}"
      unit == 1 -> "#{rounded} ms"
      2 * abs(ms) >= 3 * unit -> "#{rounded} #{name}s"
      true -> "#{rounded} #{name}"
    end
  end
end
