defmodule Ms.RegressionTest do
  use ExUnit.Case, async: true

  test "raw input is limited before trimming" do
    assert Ms.parse(String.duplicate(" ", 100) <> "1s") == :error
    assert Ms.parse("1s" <> String.duplicate(" ", 100)) == :error
    assert Ms.parse(String.duplicate(" ", 1_000_000) <> "1s") == :error
  end

  test "the 100-byte boundary includes padding" do
    assert Ms.parse(String.duplicate(" ", 98) <> "1s") == 1000
    assert Ms.parse(String.duplicate("1", 100)) == String.to_integer(String.duplicate("1", 100))
    assert Ms.parse(String.duplicate("1", 101)) == :error
    assert Ms.parse(String.duplicate("\u00A0", 50) <> "1s") == :error
  end

  test "malformed decimals cannot turn into compound durations" do
    for input <- ["1.", "1..2h", "1.2.3h", ".", "..5h", "1.h", "1h2."] do
      assert Ms.parse(input) == :error, input
    end
  end

  test "compound segments require explicit units" do
    for input <- ["1 2", "1h 30", "1h.5", "1 2h", "1ms 2 3s"] do
      assert Ms.parse(input) == :error, input
    end
  end

  test "compound fractions round only after addition" do
    assert Ms.parse("0.5ms 0.5ms") == 1
    assert Ms.parse("0.4ms 0.4ms") == 1
    assert Ms.parse("-0.5ms 0.5ms") == -1
    assert Ms.parse(".0004s.4ms") == 1
    assert Ms.parse(".4ms.0004s") == 1
  end

  test "decimal precision is preserved around the rounding midpoint" do
    assert Ms.parse("1.49999999999999999999ms") == 1
    assert Ms.parse("-1.49999999999999999999ms") == -1
    assert Ms.parse("1.50000000000000000001ms") == 2
    assert Ms.parse("-1.50000000000000000001ms") == -2
    assert Ms.parse("9007199254740993.0ms") == 9_007_199_254_740_993
  end

  test "formatting preserves exact large year multiples" do
    value = Ms.parse("9007199254740993y")
    assert Ms.format(value) == "9007199254740993y"
    assert Ms.format(-value, long: true) == "-9007199254740993 years"
    assert Ms.parse(Ms.format(value)) == value
  end

  test "formatting arbitrary integers never converts to floats" do
    years = Integer.pow(10, 309)
    assert Ms.format(years * 31_557_600_000) == "#{years}y"
    assert Ms.format(-years * 31_557_600_000) == "-#{years}y"
  end

  test "large formatter values round correctly on both sides of a midpoint" do
    years = 9_007_199_254_740_993
    unit = 31_557_600_000

    for sign <- [-1, 1] do
      assert Ms.format(sign * (years * unit + div(unit, 2) - 1)) == "#{sign * years}y"
      assert Ms.format(sign * (years * unit + div(unit, 2))) == "#{sign * (years + 1)}y"
    end
  end
end
