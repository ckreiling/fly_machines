defmodule FlyMachinesTest do
  use ExUnit.Case
  doctest FlyMachines

  test "greets the world" do
    assert FlyMachines.hello() == :world
  end
end
