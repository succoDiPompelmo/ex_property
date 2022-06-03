defmodule Properties do

  alias PropertiesGraph.Graph

  defmodule DuplicatedPropertyError do
    defexception [:message]

    @impl true
    def exception(value) do
      %DuplicatedPropertyError{message: "the property #{value} is duplicated"}
    end
  end

  defmacro __using__(modules: modules) do
    IO.puts("using properties")

    quote do
      @modules unquote(modules)
      @before_compile Properties
    end
  end

  defmacro __before_compile__(%{module: module}) do
    IO.puts("before compile properties (#{module})")
    modules = Module.get_attribute(module, :modules, [])

    # fetch all properties
    properties = resolve_properties(modules)

    #  ensure not duplicated properties
    for {name, [{mod, _, _} | _] = mods} <-
          Enum.group_by(properties, fn {{_, name}, _} -> name end) do
      if not Enum.all?(mods, &match?({{^mod, _}, _}, &1)) do
        raise DuplicatedPropertyError, name
      end
    end

    building_order = Graph.building_order(properties, module)

    quote do
      @spec new(input()) :: map()
      def new(input) do
        Properties.build(unquote(building_order), input)
      end

      unquote(generate_specs(properties))
    end
  end

  defp generate_specs(properties) do
    fields =
      properties
      |> Enum.uniq_by(fn {{_, property_name}, _} -> property_name end)
      |> Enum.map(fn {{module_name, property_name}, _} ->
        {_name = property_name, {{:., [], [{:__aliases__, [alias: false], split_module(module_name)}, property_name]}, [], []}}
      end)
    map = {:%{}, [], fields}

    quote do
      @type properties :: unquote(map)
    end
  end

  @spec split_module(atom()) :: [atom()]
  defp split_module(module_name) do
    module_name
      |> Atom.to_string()
      |> String.split(".")
      |> Enum.drop(1)
      |> Enum.map(&String.to_atom/1)
  end

  defp resolve_properties(modules) do
    properties =
      for mod <- modules,
          {prop, deps} <- mod.properties() do
        {{mod, prop}, deps}
      end

    for {prop, deps} <- properties do
      deps =
        for dep <- deps do
          properties |> Enum.find(&match?({{_, ^dep}, _}, &1)) |> elem(0)
        end

      {prop, deps}
    end
  end

  def build(properties, input) do
    for {mod, name} <- properties, reduce: %{} do
      it ->
        value = apply(mod, name, [input, it])
        Map.put(it, name, value)
    end
  end
end
