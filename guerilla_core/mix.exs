defmodule Guerilla.MixProject do
  use Mix.Project

  def project do
    [
      app: :guerilla_core,
      version: "0.1.0",
      elixir: "~> 1.12-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Guerilla.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gun, "~> 1.3"},
    ]
  end
end
