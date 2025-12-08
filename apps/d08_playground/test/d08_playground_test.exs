defmodule D08PlaygroundTest do
  use ExUnit.Case
  doctest D08Playground

  test "greets the world" do
    assert D08Playground.hello() == :world
  end
end
