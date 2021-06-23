defmodule Guerilla.Dist.Proxy do
  @moduledoc false
  
  alias Guerilla.Dist.Helper
  alias Guerilla.Gateway.Allocator
  require Logger

  @distribution_protocol 5

  def start_link do
    Allocator.start_link(name: Allocator)
  end

  def register_node(name, port, _family) do
    register_node(name, port)
  end

  def register_node(name, port) do
    Logger.info("Register node, name = #{inspect(name)}, port = #{inspect(port)}")
    {:ok, :rand.uniform(3)}
  end

  def address_please(name, host, address_family) do
    Logger.info("Address please, name = #{inspect(name)}, host = #{inspect(host)}, address_family = #{inspect(address_family)}")
    
    if Helper.same_cluster?(host) do
      {:ok, {127, 0, 0, 1}, Helper.dist_port(name), @distribution_protocol}
    else
      case Allocator.allocate(Allocator, name, host, address_family) do
        {:ok, proxy_port} ->
          {:ok, {127, 0, 0, 1}, proxy_port, @distribution_protocol}

        {:error, reason} ->
          {:error, {:alloate, reason}}
      end
    end
  end

  def names(_hostname) do
    # TODO
    {:error, :address}
  end
end