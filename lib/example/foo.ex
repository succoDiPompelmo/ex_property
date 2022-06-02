defmodule Example.Foo do
  @moduledoc false

  use Property, context: Example.Props

  @type input :: integer()

  @type p :: integer()
  property p(i, _) do
    i + 1
  end

  @type q :: integer()
  @spec q(Example.Props.input(), Example.Props.properties()) :: q()
  property q(i, %{p: 3}), do: i * 5

  property q(i, %{p: p}) when p > 0, do: i * 5

  property q(i, %{p: p}), do: p * i

  @type r :: integer()
  @spec r(Example.Props.input(), Example.Props.properties()) :: r()
  property r(_, %{p: p, q: q, z: _z}) do
    p * q
  end

  @type z :: integer()
  @spec z(Example.Props.input(), Example.Props.properties()) :: z()
  property z(_, %{q: q}) do
    q * 5
  end
end
