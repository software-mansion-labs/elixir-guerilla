defmodule Guerilla.Gateway.Client.Local do
  @moduledoc """
  This module is responsible for setting up a local TCP socket for intercepting
  the connection to the remote node set up via inet_tcp_dist.
  """

  use GenServer
  require Record
  require Logger
  alias Guerilla.Gateway.Client.LocalProtocol

  Record.defrecord :state, listener_pid: nil, listener_ref: nil

  @spec start_link(pos_integer, String.t, GenServer.options) :: GenServer.on_start
  def start_link(local_port, remote_uri, options \\ []) do
    GenServer.start_link(__MODULE__, {local_port, remote_uri}, options)
  end

  @impl true
  def init({local_port, remote_uri}) do
    transport_options = [
      port: local_port,
      ip: {127, 0, 0, 1},
    ]

    protocol_options = [
      log_label: "127.0.0.1:#{local_port} -> #{remote_uri}",
    ]

    listener_ref = make_ref()

    with {:ok, listener_pid} <- :ranch.start_listener(listener_ref, :ranch_tcp, transport_options, LocalProtocol, protocol_options),
       :ok <- :ranch.set_max_connections(listener_ref, 1) do
      {:ok, state(listener_pid: listener_pid, listener_ref: listener_ref)}
    else
      {:error, reason} ->
        {:error, {:listener, reason}}
    end
  end
end