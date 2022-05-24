defmodule Example.Bar do
  @moduledoc false

  use Property, context: Example.Props

  @type input :: integer()

  @type color :: :red
  property color(_i, %{p: _}) do
    :red
  end

  @type p2 :: String.t
  property p2(_, _), do: "ciao"
end
