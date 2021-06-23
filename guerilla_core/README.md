# Guerilla

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `guerilla` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:guerilla, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/guerilla](https://hexdocs.pm/guerilla).

## Usage

```
mix compile
iex --erl "-start_epmd false -pa _build/dev/lib/guerilla_core/ebin -proto_dist Elixir.Guerilla.Dist.Proxy -epmd_module Elixir.Guerilla.Dist.Proxy" --name node1@cluster-a.mydomain.com
iex --erl "-start_epmd false -pa _build/dev/lib/guerilla_core/ebin -proto_dist Elixir.Guerilla.Dist.Proxy -epmd_module Elixir.Guerilla.Dist.Proxy" --name node2@cluster-a.mydomain.com
iex --erl "-start_epmd false -pa _build/dev/lib/guerilla_core/ebin -proto_dist Elixir.Guerilla.Dist.Proxy -epmd_module Elixir.Guerilla.Dist.Proxy" --name node3@cluster-b.mydomain.com
iex --erl "-start_epmd false -pa _build/dev/lib/guerilla_core/ebin -proto_dist Elixir.Guerilla.Dist.Proxy -epmd_module Elixir.Guerilla.Dist.Proxy" --name node4@cluster-b.mydomain.com
```
