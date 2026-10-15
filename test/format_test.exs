defmodule Ms.FormatTest do
  use ExUnit.Case, async: true

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
end
