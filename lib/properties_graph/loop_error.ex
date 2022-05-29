defmodule PropertiesGraph.LoopError do
  defexception [:message]

  @impl true
  def exception(value) do
    %__MODULE__{message: "loop found at #{inspect(value)}"}
  end
end
