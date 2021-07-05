defmodule Guerilla.Gateway.Client do
  alias Guerilla.Gateway.Client.{Local,Remote}

  use GenServer
  require Record

  Record.defrecord :state, local_pid: nil, remote_pid: nil

  def start_link(local_port, remote_uri, options \\ []) do
    GenServer.start_link(__MODULE__, {local_port, remote_uri}, options)
  end

  @impl true
  def init({local_port, remote_uri}) do
    {:ok, local_pid} = Local.start_link(local_port, remote_uri)
    {:ok, remote_pid} = Remote.start_link(local_port, remote_uri)

    {:ok, state(local_pid: local_pid, remote_pid: remote_pid)}
  end
end