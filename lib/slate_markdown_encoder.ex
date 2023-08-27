defmodule Swole.SlateMarkdownEncoder do
  @behaviour Swole.Encoder

  @impl true
  def encode(%Swole.APISpec{} = spec, _opts) do
    doc =
      spec
      |> write_overview()
      |> write_for_paths(spec)
      # todo

    {:ok, doc}
  end

  defp write_overview(%{info: info} = _spec) do
    """
    ---
    title: #{info["title"]}

    search: true
    ---

    # #{info["title"]}

    #{info["description"]}
    """
  end

  defp write_for_paths(doc, %{paths: _paths} = _spec) do
    """
    #{doc}
    """
  end
end
