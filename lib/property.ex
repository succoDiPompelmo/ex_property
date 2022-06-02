defmodule Property do
  @moduledoc """
  Documentation for `Property`.
  """

  alias PropertiesGraph.Graph

  defmacro __using__(_) do
    IO.puts("using property")
    quote do
      import Property
      alias __MODULE__
      Module.register_attribute(__MODULE__, :property, accumulate: true)
      Module.register_attribute(__MODULE__, :definition, accumulate: true)
      @before_compile Property
    end
  end

  defmacro property(call, body) do
    property = name_and_required_properties(call)
    quote do
      @property unquote(property)
      @definition unquote(Macro.escape({call, body}))
    end
  end

  @spec name_and_required_properties(Macro.t()) :: {atom, [atom]}
  defp name_and_required_properties(ast) do
    case ast do
      {:when, _, [call, _guard]} -> name_and_required_properties(call)
      {name, _, [_input, props]} -> {name, required_properties(props)}
    end
  end

  @spec required_properties(Macro.t()) :: [atom]
  defp required_properties(ast) do
    case ast do
      {:%{}, _, props} -> Keyword.keys(props)
      {:%, _, [_alias, map]} -> required_properties(map)
      {:=, _, args} -> Enum.flat_map(args, &required_properties/1)
      {:_, _, _} -> []
    end
  end

  defmacro __before_compile__(%{module: module}) do
    IO.puts("before compile property (#{module})")
    properties = Module.get_attribute(module, :property)
    context = Module.get_attribute(module, :context)
    IO.inspect(context)
    building_order = Graph.building_order(properties, module)
    names = properties |> Keyword.keys() |> Enum.uniq()
    definitions = module |> Module.delete_attribute(:definition) |> Enum.reverse()

    quote do
      @spec new(input()) :: t()
      def new(input) do
        Property.build(__MODULE__, unquote(building_order), input)
      end

      def properties, do: unquote(properties)

      unquote(generate_type(names))
      unquote(generate_struct(names))
      unquote(generate_specs(names))
      unquote(generate_defs(definitions))
    end
  end

  # @type t :: %__MODULE__{
  #         p: p(),
  #         q: q(),
  #         r: r()
  #       }
  @spec generate_type([atom]) :: Macro.t()
  defp generate_type(names) do
    fields = Enum.map(names, &{_name = &1, {_type = &1, [], []}})
    map = {:%{}, [], fields}
    struct = {:%, [], [{:__MODULE__, [if_undefined: :apply], Elixir}, map]}

    quote do
      @type t :: unquote(struct)
    end
  end

  @spec generate_struct([atom]) :: Macro.t()
  defp generate_struct(names) do
    quote do
      defstruct unquote(names)
    end
  end

  @spec generate_specs([atom]) :: Macro.t()
  defp generate_specs(names) do

    a = {{:., [], [{:__aliases__, [alias: false], [:Example, :Props]}, :properties]}, [], []}

    specs =
      for name <- names do
        quote do
          @spec unquote(name)(input(), unquote(a)) :: unquote(name)()
        end
      end

    IO.inspect(specs)

    quote do
      (unquote_splicing(specs))
    end
  end

  @spec generate_defs([{Macro.t(), Macro.t()}]) :: Macro.t()
  defp generate_defs(definitions) do
    defs =
      for {call, body} <- definitions do
        quote do
          def unquote(call), unquote(body)
        end
      end

    quote do
      (unquote_splicing(defs))
    end
  end

  @spec build(module(), [atom()], any) :: struct()
  def build(module, properties, input) do
    for name <- properties, reduce: struct(module) do
      it ->
        value = apply(module, name, [input, it])
        Map.put(it, name, value)
    end
  end
end
