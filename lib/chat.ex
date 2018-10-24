defmodule Chat do
  @moduledoc """
  Documentation for Chat.
  """
  defstruct users: []

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %__MODULE__{}}
  end

  def connect(pid) do
    GenServer.call(__MODULE__, {:connect, pid})
  end

  def disconnect(pid) do
    GenServer.call(__MODULE__, {:disconnect, pid})
  end

  def msg(item) do
    GenServer.call(__MODULE__, {:msg, item})
  end

  def handle_call({:connect, pid}, _from, state) do
    for node <- state.users do
      :rpc.call(node, :erlang, :display, ["Connected: " <> inspect(pid)])
    end

    {:reply, {:ok, :connected}, %{state | users: [pid | state.users]}}
  end

  def handle_call({:disconnect, pid}, _from, state) do
    new_pids = Enum.filter(state.users, &(&1 != pid))

    for node <- state.users do
      :rpc.call(node, :erlang, :display, ["Disconnected: " <> inspect(pid)])
    end

    {:reply, {:ok, :disconnected}, %{state | users: new_pids}}
  end

  def handle_call({:msg, msg}, _from, state) do
    for node <- state.users do
      :rpc.call(node, :erlang, :display, [msg])
    end

    {:reply, {:ok, :sent}, state}
  end
end
