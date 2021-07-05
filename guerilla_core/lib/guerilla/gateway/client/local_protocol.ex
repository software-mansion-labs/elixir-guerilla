defmodule Guerilla.Gateway.Client.LocalProtocol do
  @moduledoc """
  This module implements a protocol for ranch listener used for intercepting
  local connections.
  """

  require Logger

  @behaviour :ranch_protocol

  @recv_timeout 1000

  @impl true
  def start_link(ref, transport, options) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, transport, options])
    {:ok, pid}
  end

  @doc false
  def init(ref, transport, options) do
    Logger.info("Local client [#{options[:log_label]}]: Connected")
    {:ok, socket} = :ranch.handshake(ref)
    loop(socket, transport, options)
  end

  @doc false
  defp loop(socket, transport, options) do
    case transport.recv(socket, 0, @recv_timeout) do
      {:ok, data} ->
        Logger.debug("Local client [#{options[:log_label]}]: Received data, data = #{inspect(data)}")
        loop(socket, transport, options)

      {:error, :timeout} ->
        loop(socket, transport, options)

      {:error, :closed} ->
        Logger.info("Local client [#{options[:log_label]}]: Disconnected")
        :ok = transport.close(socket)

      {:error, reason} ->
        Logger.warn("Local client [#{options[:log_label]}]: Error, reason = #{inspect(reason)}")
        :ok = transport.close(socket)
    end
  end
end