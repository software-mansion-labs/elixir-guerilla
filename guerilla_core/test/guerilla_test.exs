defmodule GuerillaTest do
  use ExUnit.Case
  doctest Guerilla

  test "greets the world" do
    assert Guerilla.hello() == :world
  end
end
