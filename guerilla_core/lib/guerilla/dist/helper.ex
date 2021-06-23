defmodule Guerilla.Dist.Helper do
  @moduledoc false
  
  @default_dist_port 19999

  def dist_port(name) when is_atom(name) do
    dist_port(Atom.to_string(name))
  end

  def dist_port(name) when is_list(name) do
    dist_port(List.to_string(name))
  end

  def dist_port(name) when is_binary(name) do
    base_port = Application.get_env(:guerilla_core, :dist_port, @default_dist_port)

    node_name = Regex.replace ~r/@.*$/, name, ""
    offset =
      case Regex.run ~r/[0-9]+$/, node_name do
    nil ->
      0
    [offset_as_string] ->
      String.to_integer offset_as_string
      end

    base_port + offset
  end

  def same_cluster?(other_cluster) when is_atom(other_cluster) do
    same_cluster?(Atom.to_string(other_cluster))
  end

  def same_cluster?(other_cluster) when is_list(other_cluster) do
    same_cluster?(List.to_string(other_cluster))
  end
  
  def same_cluster?(other_cluster) when is_binary(other_cluster) do
    self = Atom.to_string(Node.self())

    [_name, self_cluster] = String.split(self, "@", parts: 2)

    self_cluster == other_cluster
  end
end