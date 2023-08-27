defmodule Swole.JSONEncoder do
  @behaviour Swole.Encoder

  def encode(%Swole.APISpec{} = spec, opts \\ []) do
    Jason.encode(spec, Keyword.take(opts, [:pretty, :escape]))
  end
end
