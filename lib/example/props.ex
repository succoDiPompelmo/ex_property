defmodule Example.Props do
  @moduledoc false

  @type input :: integer()

  use Properties, modules: [
    Example.Bar,
    Example.Foo,
  ]
end
