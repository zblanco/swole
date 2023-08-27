defmodule Swole do
  @moduledoc """
  It generates API docs. It's Fork/Rewrite of the Bureaucrat library.
  """
  use Supervisor
  alias Swole.Recorder

  def start_link(opts) do
    name = opts[:name] || raise ArgumentError, "must supply a name"

    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  def child_spec(opts) do
    %{
      id: opts[:name] || raise(ArgumentError, "must supply a name"),
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def init(opts) do
    name = opts[:name]

    children = [
      {Recorder, Keyword.merge(opts, name: recorder_name(name))}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def recorder_name(name), do: :"#{name}.Swole.Recorder"

  def get_records(swole_name) do
    Recorder.get_records(recorder_name(swole_name))
  end
end
