defmodule Ms.ParseUnitsTest do
  use ExUnit.Case, async: true

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
end
