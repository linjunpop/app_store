defmodule AppStore.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/linjunpop/app_store"

  def project do
    [
      app: :app_store,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "App Store Server API",
      description: "A thin App Store Server API Client",
      source_url: @url,
      homepage_url: @url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AppStore.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}

      # runtime deps
      {:finch, "~> 0.6", optional: true},
      {:jason, "~> 1.0", optional: true},

      # doc
      {:ex_doc, "~> 0.14", only: [:dev, :docs]}
    ]
  end
end
