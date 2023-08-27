defmodule Swole.Recorder do
  use GenServer
  require Logger

  # alias Phoenix.Socket
  # alias Phoenix.Socket.Broadcast
  # alias Phoenix.Socket.Message
  # alias Phoenix.Socket.Reply
  alias Plug.Conn

  def child_spec(opts) do
    %{
      id: opts[:name],
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  # def doc(%Broadcast{} = broadcast, opts) do
  #   GenServer.cast(__MODULE__, {:channel_doc, broadcast, opts})
  # end

  # def doc(%Message{} = message, opts) do
  #   GenServer.cast(__MODULE__, {:channel_doc, message, opts})
  # end

  # def doc(%Reply{} = reply, opts) do
  #   GenServer.cast(__MODULE__, {:channel_doc, reply, opts})
  # end

  # def doc({_, _, %Socket{}} = join_socket, opts) do
  #   GenServer.cast(__MODULE__, {:channel_doc, join_socket, opts})
  # end

  def doc(recorder, %Plug.Conn{} = conn, opts) do
    GenServer.cast(recorder, {:doc, conn, opts})
  end

  def get_records(recorder) do
    GenServer.call(recorder, :get_records)
  end

  def init(opts) do
    state =
      opts
      |> Map.new()
      |> Map.put(:records, [])

    {:ok, state}
  end

  def handle_cast({:doc, conn, opts}, state) do
    conn =
      conn
      |> Conn.assign(:swole_desc, opts[:description])
      |> Conn.assign(:swole_file, opts[:file])
      |> Conn.assign(:swole_line, opts[:line])
      |> Conn.assign(:swole_opts, opts)

    Logger.debug("Recording conn doc gen")

    {:noreply, Map.put(state, :records, [conn | state.records])}
  end

  def handle_call(:get_records, _from, state) do
    {:reply, state.records, state}
  end
end
