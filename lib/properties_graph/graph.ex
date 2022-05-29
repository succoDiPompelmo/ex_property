defmodule PropertiesGraph.Graph do

  alias PropertiesGraph.LoopError

  @spec building_order([{atom, [atom]}]) :: [atom]
  def building_order(properties) do

    graph =
      for {property, _} <- properties, reduce: Graph.new() do
        g -> Graph.add_vertex(g, property)
      end

    graph =
      for {property, depends_on} <- properties,
          other_property <- depends_on,
          reduce: graph do
        g -> Graph.add_edge(g, other_property, property)
      end

    if Graph.is_cyclic?(graph) do
      raise LoopError, Graph.loop_vertices(graph)
    end

    dot_output(graph)

    Graph.topsort(graph)
  end

  defp dot_output(graph) do
    {:ok, dot_graph} = Graph.Serializers.DOT.serialize(graph)

    File.write!("graph.dot", dot_graph)
  end

end
