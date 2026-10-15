defmodule Ms.ParseTest do
  use ExUnit.Case, async: true

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
end
