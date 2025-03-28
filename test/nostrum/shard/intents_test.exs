defmodule Nostrum.Shard.IntentsTest do
  use ExUnit.Case, async: true

  alias Nostrum.Shard.Intents

  describe "get_enabled_intents/0" do
    test "returns all intents enabled when all intents are set" do
      result = Intents.get_enabled_intents(:all)

      # Value of all intents
      expected = 53_608_447

      assert(^result = expected)
    end

    test "returns all non-privileged intents enabled when intents set to :nonprivileged (default)" do
      result = Intents.get_enabled_intents(:nonprivileged)

      # Value of all non-privileged intents
      expected = 53_608_447 - (2 + 256 + 32_768)

      assert(^result = expected)
    end

    test "returns 0 when no intents are enabled" do
      result = Intents.get_enabled_intents([])

      expected = 0

      assert(^result = expected)
    end

    test "returns 1 when guild intent is enabled" do
      result = Intents.get_enabled_intents([:guilds])

      expected = 1

      assert(^result = expected)
    end
  end

  describe "get_intent_value/1" do
    test "returns 1 when guild intent is enabled" do
      result = Intents.get_intent_value([:guilds])

      expected = 1

      assert(^result = expected)
    end

    test "raises exception when invalid intent is passed" do
      assert_raise(RuntimeError, "Invalid intent specified: craig_cat", fn ->
        Intents.get_intent_value([:guilds, :craig_cat])
      end)
    end
  end
end
