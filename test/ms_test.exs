defmodule MsTest do
  use ExUnit.Case, async: true
  doctest Ms

  describe "parse/1 - milliseconds" do
    test "bare number defaults to ms" do
      assert Ms.parse("100") == 100
      assert Ms.parse("0") == 0
    end

    test "explicit ms units" do
      assert Ms.parse("100ms") == 100
      assert Ms.parse("100 ms") == 100
      assert Ms.parse("50msec") == 50
      assert Ms.parse("50msecs") == 50
      assert Ms.parse("200millisecond") == 200
      assert Ms.parse("200milliseconds") == 200
    end
  end

  describe "parse/1 - seconds" do
    test "all second aliases" do
      assert Ms.parse("1s") == 1_000
      assert Ms.parse("1sec") == 1_000
      assert Ms.parse("5secs") == 5_000
      assert Ms.parse("1second") == 1_000
      assert Ms.parse("2seconds") == 2_000
    end
  end

  describe "parse/1 - minutes" do
    test "all minute aliases" do
      assert Ms.parse("1m") == 60_000
      assert Ms.parse("1min") == 60_000
      assert Ms.parse("3mins") == 180_000
      assert Ms.parse("1minute") == 60_000
      assert Ms.parse("2minutes") == 120_000
    end
  end

  describe "parse/1 - hours" do
    test "all hour aliases" do
      assert Ms.parse("1h") == 3_600_000
      assert Ms.parse("1hr") == 3_600_000
      assert Ms.parse("2hrs") == 7_200_000
      assert Ms.parse("1hour") == 3_600_000
      assert Ms.parse("2hours") == 7_200_000
    end
  end

  describe "parse/1 - days" do
    test "all day aliases" do
      assert Ms.parse("1d") == 86_400_000
      assert Ms.parse("1day") == 86_400_000
      assert Ms.parse("3days") == 259_200_000
    end
  end

  describe "parse/1 - weeks" do
    test "all week aliases" do
      assert Ms.parse("1w") == 604_800_000
      assert Ms.parse("1wk") == 604_800_000
      assert Ms.parse("2wks") == 1_209_600_000
      assert Ms.parse("1week") == 604_800_000
      assert Ms.parse("2weeks") == 1_209_600_000
    end
  end

  describe "parse/1 - months" do
    test "all month aliases" do
      assert Ms.parse("1mo") == 2_629_800_000
      assert Ms.parse("1month") == 2_629_800_000
      assert Ms.parse("2months") == 5_259_600_000
    end
  end

  describe "parse/1 - years" do
    test "all year aliases" do
      assert Ms.parse("1y") == 31_557_600_000
      assert Ms.parse("1yr") == 31_557_600_000
      assert Ms.parse("2yrs") == 63_115_200_000
      assert Ms.parse("1year") == 31_557_600_000
      assert Ms.parse("2years") == 63_115_200_000
    end
  end

  describe "parse/1 - decimals" do
    test "decimal hours" do
      assert Ms.parse("1.5h") == 5_400_000
    end

    test "decimal days" do
      assert Ms.parse("0.5d") == 43_200_000
    end

    test "leading dot" do
      assert Ms.parse(".5s") == 500
    end

    test "decimal minutes" do
      assert Ms.parse("2.5m") == 150_000
    end
  end

  describe "parse/1 - compound durations" do
    test "two units with space" do
      assert Ms.parse("1h 30m") == 5_400_000
    end

    test "two units without space" do
      assert Ms.parse("1h30m") == 5_400_000
    end

    test "three units" do
      assert Ms.parse("1d 12h 30m") == 131_400_000
    end

    test "mixed units" do
      assert Ms.parse("2h 30s") == 7_230_000
    end

    test "compound with decimals" do
      assert Ms.parse("1.5h 30s") == 5_430_000
    end
  end

  describe "parse/1 - case insensitivity" do
    test "uppercase single letter" do
      assert Ms.parse("2H") == 7_200_000
    end

    test "mixed case" do
      assert Ms.parse("1Day") == 86_400_000
    end

    test "all caps" do
      assert Ms.parse("3HOURS") == 10_800_000
      assert Ms.parse("100MS") == 100
    end
  end

  describe "parse/1 - long unit names" do
    test "parses long names with space" do
      assert Ms.parse("2 hours") == 7_200_000
      assert Ms.parse("1 day") == 86_400_000
      assert Ms.parse("500 milliseconds") == 500
      assert Ms.parse("3 minutes") == 180_000
    end
  end

  describe "parse/1 - negative values" do
    test "negative with short unit" do
      assert Ms.parse("-100ms") == -100
      assert Ms.parse("-2h") == -7_200_000
    end

    test "negative with decimal" do
      assert Ms.parse("-1.5d") == -129_600_000
    end

    test "positive sign" do
      assert Ms.parse("+2h") == 7_200_000
    end
  end

  describe "parse/1 - whitespace handling" do
    test "leading and trailing whitespace" do
      assert Ms.parse("  2h  ") == 7_200_000
    end

    test "multiple spaces between number and unit" do
      assert Ms.parse("1   s") == 1_000
    end
  end

  describe "parse/1 - edge cases" do
    test "empty string" do
      assert Ms.parse("") == :error
    end

    test "whitespace only" do
      assert Ms.parse("   ") == :error
    end

    test "non-string input" do
      assert Ms.parse(123) == :error
      assert Ms.parse(nil) == :error
    end

    test "unknown unit" do
      assert Ms.parse("2x") == :error
    end

    test "no number" do
      assert Ms.parse("abc") == :error
    end

    test "string too long" do
      assert Ms.parse(String.duplicate("1", 101)) == :error
    end

    test "very large number" do
      assert Ms.parse("1000y") == 31_557_600_000_000
    end
  end

  describe "parse!/1" do
    test "returns value on success" do
      assert Ms.parse!("2h") == 7_200_000
      assert Ms.parse!("500ms") == 500
    end

    test "raises on invalid input" do
      assert_raise ArgumentError, fn -> Ms.parse!("") end
      assert_raise ArgumentError, fn -> Ms.parse!("invalid") end
    end
  end

  describe "format/1 - short" do
    test "milliseconds" do
      assert Ms.format(0) == "0ms"
      assert Ms.format(500) == "500ms"
      assert Ms.format(999) == "999ms"
    end

    test "seconds" do
      assert Ms.format(1_000) == "1s"
      assert Ms.format(5_000) == "5s"
    end

    test "minutes" do
      assert Ms.format(60_000) == "1m"
      assert Ms.format(120_000) == "2m"
    end

    test "hours" do
      assert Ms.format(3_600_000) == "1h"
      assert Ms.format(7_200_000) == "2h"
    end

    test "days" do
      assert Ms.format(86_400_000) == "1d"
    end

    test "weeks" do
      assert Ms.format(604_800_000) == "1w"
    end

    test "months" do
      assert Ms.format(2_629_800_000) == "1mo"
    end

    test "years" do
      assert Ms.format(31_557_600_000) == "1y"
    end

    test "rounding" do
      assert Ms.format(1_500) == "2s"
      assert Ms.format(234_234_234) == "3d"
    end

    test "negative values" do
      assert Ms.format(-500) == "-500ms"
      assert Ms.format(-3_600_000) == "-1h"
    end
  end

  describe "format/2 - long" do
    test "milliseconds" do
      assert Ms.format(0, long: true) == "0 ms"
      assert Ms.format(500, long: true) == "500 ms"
    end

    test "singular" do
      assert Ms.format(1_000, long: true) == "1 second"
      assert Ms.format(60_000, long: true) == "1 minute"
      assert Ms.format(3_600_000, long: true) == "1 hour"
      assert Ms.format(86_400_000, long: true) == "1 day"
      assert Ms.format(604_800_000, long: true) == "1 week"
      assert Ms.format(2_629_800_000, long: true) == "1 month"
      assert Ms.format(31_557_600_000, long: true) == "1 year"
    end

    test "plural" do
      assert Ms.format(2_000, long: true) == "2 seconds"
      assert Ms.format(120_000, long: true) == "2 minutes"
      assert Ms.format(7_200_000, long: true) == "2 hours"
      assert Ms.format(172_800_000, long: true) == "2 days"
      assert Ms.format(1_209_600_000, long: true) == "2 weeks"
      assert Ms.format(5_259_600_000, long: true) == "2 months"
      assert Ms.format(63_115_200_000, long: true) == "2 years"
    end

    test "pluralization threshold at 1.5x" do
      assert Ms.format(1_499, long: true) == "1 second"
      assert Ms.format(1_500, long: true) == "2 seconds"
    end
  end

  describe "format/1 - edge cases" do
    test "non-integer raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn -> Ms.format(List.first([1.5])) end
      assert_raise FunctionClauseError, fn -> Ms.format(List.first(["bad"])) end
    end
  end

  describe "roundtrip" do
    test "parse then format for exact multiples" do
      for {str, ms} <- [
            {"1s", 1_000},
            {"1m", 60_000},
            {"1h", 3_600_000},
            {"1d", 86_400_000},
            {"1w", 604_800_000}
          ] do
        assert Ms.parse(Ms.format(ms)) == ms, "roundtrip failed for #{str}"
      end
    end

    test "parse then format with long option" do
      assert Ms.parse(Ms.format(3_600_000, long: true)) == 3_600_000
      assert Ms.parse(Ms.format(7_200_000, long: true)) == 7_200_000
    end
  end
end
