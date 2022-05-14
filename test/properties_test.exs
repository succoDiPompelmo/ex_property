defmodule PropertiesTest do
  use ExUnit.Case

  test "greets the world" do
    assert %Properties{q: 10} = Properties.new(2) |> IO.inspect(label: :result)
  end
end
