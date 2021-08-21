defmodule AppStore.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/linjunpop/app_store"

  def project do
    [
      app: :app_store,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "App Store",
      description: "A thin App Store Server API Client",
      source_url: @url,
      homepage_url: @url,
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AppStore.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}

      # runtime deps
      {:finch, "~> 0.6"},
      {:jason, "~> 1.0"},

      # JWT
      {:joken, "~> 2.0"},

      # NanoID
      {:nanoid, "~> 2.0.5"},

      # doc
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},

      # test
      {:bypass, "~> 2.1", only: :test}
    ]
  end

  defp package do
    [
      name: :app_store,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Jun Lin"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      groups_for_modules: [
        Token: [
          ~r"AppStore.Token"
        ],
        API: [
          ~r"AppStore.API"
        ],
        "HTTP Client": [
          ~r"AppStore.HTTPClient"
        ],
        JSON: [
          ~r"AppStore.JSON"
        ]
      ]
    ]
  end
end
