defmodule MsTest do
  use ExUnit.Case, async: true
  doctest Ms

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
