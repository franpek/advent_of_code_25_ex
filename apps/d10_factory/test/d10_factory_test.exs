defmodule D10FactoryTest do
  use ExUnit.Case
  doctest D10Factory

  test "greets the world" do
    assert D10Factory.hello() == :world
  end
end
