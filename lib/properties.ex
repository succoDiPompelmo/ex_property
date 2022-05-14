defmodule Properties do
  use Property

  # TODO: "when" clause
  # TODO: struct as argument

  @type input :: integer()

  @type p :: integer()
  property p(i, _) do
    i + 1
  end

  @type q :: integer()
  property q(i, %{p: 2}), do: i * 2

  property q(i, %{p: p}), do: p * i

  @type r :: integer()
  property r(_, %{p: p, q: q, z: _z}) do
    p * q
  end

  @type z :: integer()
  property z(_, %{q: q}) do
    q * 5
  end
end
