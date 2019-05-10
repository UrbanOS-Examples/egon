defmodule EgonTest do
  use ExUnit.Case
  doctest Egon

  test "greets the world" do
    assert Egon.hello() == :world
  end
end
