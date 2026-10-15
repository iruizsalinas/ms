defmodule Ms.InvariantsTest do
  use ExUnit.Case, async: true

  # Independent reference values: do not derive expected results from Ms.Units.
  @units [
    {1, "ms", "millisecond"},
    {1000, "s", "second"},
    {60_000, "m", "minute"},
    {3_600_000, "h", "hour"},
    {86_400_000, "d", "day"},
    {604_800_000, "w", "week"},
    {2_629_800_000, "mo", "month"},
    {31_557_600_000, "y", "year"}
  ]

  test "generated compound decimals agree with an integer reference total" do
    :rand.seed(:exsss, {123, 456, 789})

    for _ <- 1..2000 do
      sign = if :rand.uniform(2) == 1, do: -1, else: 1

      parts =
        for _ <- 1..:rand.uniform(3) do
          {unit, short, _} = Enum.at(@units, :rand.uniform(length(@units)) - 1)
          places = :rand.uniform(4) - 1
          scale = Integer.pow(10, places)
          number = :rand.uniform(10_000) - 1
          whole = Integer.to_string(div(number, scale))
          fraction = Integer.to_string(rem(number, scale)) |> String.pad_leading(places, "0")
          token = if places == 0, do: whole, else: whole <> "." <> fraction
          {token <> short, number * unit * div(1000, scale)}
        end

      input = if(sign < 0, do: "-", else: "+") <> Enum.map_join(parts, " ", &elem(&1, 0))
      total = Enum.reduce(parts, 0, fn {_, value}, acc -> acc + value end)
      expected = sign * div(total + 500, 1000)
      assert byte_size(input) <= 100
      assert Ms.parse(input) == expected, input
      assert Ms.parse(String.upcase(input)) == expected, input
    end
  end

  test "unit thresholds and negative ties retain their documented behavior" do
    for {unit, short, name} <- tl(@units), sign <- [-1, 1] do
      for {offset, rounded, plural} <- [
            {0, 1, ""},
            {div(unit, 2) - 1, 1, ""},
            {div(unit, 2), 2, "s"}
          ] do
        value = sign * (unit + offset)
        assert Ms.format(value) == "#{sign * rounded}#{short}"
        assert Ms.format(value, long: true) == "#{sign * rounded} #{name}#{plural}"
      end
    end
  end

  test "exact unit values survive parsing and formatting" do
    for {unit, short, _} <- @units, sign <- [-1, 1] do
      assert Ms.parse("#{sign}#{short}") == sign * unit
      assert Ms.parse(Ms.format(sign * unit)) == sign * unit
      assert Ms.parse(Ms.format(sign * unit, long: true)) == sign * unit
    end
  end

  test "bounded arbitrary binary inputs never raise" do
    :rand.seed(:exsss, {987, 654, 321})

    for _ <- 1..5000 do
      size = :rand.uniform(102) - 1
      bytes = for _ <- List.duplicate(nil, size), do: :rand.uniform(256) - 1
      result = Ms.parse(:binary.list_to_bin(bytes))
      assert result == :error or is_integer(result)
    end
  end

  test "invalid syntax and invalid UTF-8 fail through both parsing APIs" do
    for input <- [
          "",
          " ",
          "+",
          "-",
          "--1h",
          "1h-30m",
          "1h+30m",
          "1e3s",
          "1,5h",
          "1h\n30m",
          "1\ns",
          "Infinity",
          "NaN",
          "1x",
          <<255>>,
          <<49, 255>>,
          nil,
          100,
          1.5,
          [],
          %{}
        ] do
      assert Ms.parse(input) == :error
      assert_raise ArgumentError, fn -> Ms.parse!(input) end
    end
  end

  test "truthy and falsy long options retain existing keyword behavior" do
    assert Ms.format(1000, long: nil) == "1s"
    assert Ms.format(1000, long: :yes) == "1 second"
  end
end
