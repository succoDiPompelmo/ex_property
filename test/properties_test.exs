defmodule PropertiesTest do
  use ExUnit.Case

  # test "calculating properties from input" do
  #   assert %{q: 10} = Example.new(2) |> IO.inspect(label: :result)
  # end

  test "calculating properties from multiple modules" do
    assert %{q: 10} = Example.Props.new(2) |> IO.inspect(label: :result)
  end
end
