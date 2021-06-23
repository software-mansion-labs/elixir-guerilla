defmodule Guerilla.SampleTest do
  use ExUnit.Case
  doctest Guerilla.Sample

  test "greets the world" do
    assert Guerilla.Sample.hello() == :world
  end
end
