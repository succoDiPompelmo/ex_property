defmodule Properties do
  use Property

  @type input :: integer()

  @type p :: integer()
  property p(i, _) do
    i + 1
  end

  @type q :: integer()
  property q(i, %Properties{p: 3}), do: i * 5

  property q(i, %Properties{p: p}) when p > 0, do: i * 5

  property q(i, %Properties{p: p}), do: p * i

  @type r :: integer()
  property r(_, %Properties{p: p, q: q, z: _z}) do
    p * q
  end

  @type z :: integer()
  property z(_, %__MODULE__{q: q}) do
    q * 5
  end
end
