defmodule Example.Bar do
  @moduledoc false

  use Property

  @type input :: integer()

  @type color :: :red
  @spec color(Example.Props.input(), Example.Props.properties()) :: color()
  property color(_i, %{p: _}) do
    :red
  end

  @type p2 :: String.t
  @spec p2(Example.Props.input(), Example.Props.properties()) :: p2()
  property p2(_, _), do: "ciao"
end
