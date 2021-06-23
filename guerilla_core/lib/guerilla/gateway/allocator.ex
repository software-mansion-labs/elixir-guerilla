defmodule Guerilla.Gateway.Allocator do
  @moduledoc """
  This module implements a registy of mappings for local port numbers used for
  wrapping TCP connections over WebSockets and associated remote node names. 
  """

  use GenServer
  require Logger
  require Record

  @default_timeout 3000
  @allocations_table_name :guerilla_allocations
  @port_min 50000
  @port_max 60000

  Record.defrecord :state, free_ports: [], allocations_table: nil

  @spec start_link(GenServer.options) :: GenServer.on_start
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, [], options)
  end

  def allocate(server, name, host, address_family, timeout \\ @default_timeout) do
    GenServer.call(server, {:allocate, name, host, address_family}, timeout)
  end

  @impl true
  def init(_) do
    allocations_table = :ets.new(@allocations_table_name, [:protected, :set])
    free_ports = 
      Range.new(@port_min, @port_max)
      |> Enum.to_list()
      |> Enum.shuffle()

    {:ok, state(allocations_table: allocations_table, free_ports: free_ports)}
  end

  @impl true
  def handle_call({:allocate, name, host, address_family}, _from, state(free_ports: []) = state) do
    Logger.warn("Allocate: No free port available, unable to allocate for #{name}@#{host} (#{address_family})")
    {:reply, {:error, :nofreeports}, state}
  end

  def handle_call({:allocate, name, host, address_family}, _from, state(free_ports: [next_free_port|remaining_free_ports]) = state) do
    Logger.info("Allocate: Allocating #{next_free_port} for #{name}@#{host} (#{address_family})")

    {:reply, {:ok, next_free_port}, state(state, free_ports: remaining_free_ports)}
  end
end