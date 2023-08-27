defmodule Swole.Formatter do
  use GenServer
  require Logger
  alias Swole.APISpec

  def init(config) do
    {:ok, config[:swole]}
  end

  def handle_cast({:suite_finished, _run_us, _load_us}, config) do
    suite_finished(config)
  end

  def handle_cast({:suite_finished, _times_us}, config) do
    suite_finished(config)
  end

  def handle_cast(_event, config) do
    {:noreply, config}
  end

  defp suite_finished(config) do
    if should_generate_docs?(config), do: generate_docs(config)

    {:noreply, nil}
  end

  defp should_generate_docs?(config) do
    env_var = config[:env_var] || "DOC"

    System.get_env(env_var) == "true"
  end

  defp generate_docs(config) do
    records = Swole.get_records(config[:name])

    api_spec = APISpec.new(config, records) |> dbg()
    # consider spec validation to raise an error

    writers = config[:writers]

    Enum.map(writers, fn %{encoder: encoder, path: path} ->
      case encoder.encode(api_spec) do
        {:ok, encoded} ->
          File.write!(path, encoded)

        {:error, error} ->
          raise error
      end
    end)
  end
end
