defmodule Guerilla.Gateway.Client.Remote do
  @moduledoc """
  This module is responsible for establishing the WebSocket connection to 
  the remote cluster's gateway.
  """

  use GenServer
  require Record
  require Logger

  Record.defrecord :state, remote_stream: nil, log_label: nil

  @spec start_link(String.t, GenServer.options) :: GenServer.on_start
  def start_link(local_port, remote_uri, options \\ []) do
    GenServer.start_link(__MODULE__, {local_port, remote_uri}, options)
  end

  @impl true
  def init({local_port, remote_uri}) do
    {host, port, protocol, path} = parse_uri(remote_uri)
    
    log_label = "127.0.0.1:#{local_port} -> #{remote_uri}"

    connect_opts = %{
      connect_timeout: :timer.minutes(1),
      retry: 10,
      retry_timeout: 100,
      protocols: [protocol]
    }

    with {:ok, gun} <- :gun.open(host, port, connect_opts),
         :ok <- Logger.debug("Remote gateway [#{log_label}]: Connected, host = #{inspect(host)}, port = #{inspect(port)}"),
         {:ok, protocol} <- :gun.await_up(gun),
         :ok <- Logger.debug("Remote gateway [#{log_label}]: Protocol ready, protocol = #{inspect(protocol)}"),
         stream <- :gun.ws_upgrade(gun, path, []),
         :ok <- Logger.debug("Remote gateway [#{log_label}]: Upgraded connection to WebSocket")         
    do
      {:ok, state(remote_stream: stream, log_label: log_label)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # @impl true
  # def handle_info({:gun_response, _from, })


  defp parse_uri(uri_string) do
    uri = URI.parse(uri_string)

    host = case uri.host do
      nil ->
        raise "Missing host in the given URI #{inspect(uri_string)}"
      other ->
        to_charlist(other) 
    end

    port = case uri.port do
      nil ->
        case uri.scheme do
          "ws" ->
            80
          "wss" ->
            443
          nil ->
            raise "Missing scheme in the given URI #{inspect(uri_string)}, it has to be either ws:// or wss://"
          other ->
            raise "Invalid scheme #{other} in the given URI #{inspect(uri_string)}, it has to be either ws:// or wss://"
        end
      other ->
        other
    end

    protocol = case uri.scheme do
      "ws" ->
        :http
      "wss" ->
        :https
      nil ->
        raise "Missing scheme in the given URI #{inspect(uri_string)}, it has to be either ws:// or wss://"
      other ->
        raise "Invalid scheme #{other} in the given URI #{inspect(uri_string)}, it has to be either ws:// or wss://"    
    end

    path = case uri.path do
      nil ->
        "/"
      other ->
        other
    end

    {host, port, protocol, path}
  end
end