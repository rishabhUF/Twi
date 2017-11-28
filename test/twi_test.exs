defmodule TwiTest do
  use ExUnit.Case
  doctest Twi

  test "greets the world" do
    assert Twi.hello() == :world
  end
end
