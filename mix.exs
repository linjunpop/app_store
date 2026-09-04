defmodule AppStore.MixProject do
  use Mix.Project

  @version "0.5.0"
  @url "https://github.com/linjunpop/app_store"

  def project do
    [
      app: :app_store,
      version: @version,
      elixir: "~> 1.15",
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
      # runtime deps
      {:finch, "~> 0.23"},
      {:jason, "~> 1.4"},

      # JWT
      {:joken, "~> 2.7"},

      # doc
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},

      # test
      {:passby, "~> 0.2", only: :test},
      {:mox, "~> 1.1", only: :test}
    ]
  end

  defp package do
    [
      name: :app_store,
      files: ["lib", "guides", "mix.exs", "README*", "LICENSE"],
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
      extras: [
        "README.md",
        "guides/getting-started.md",
        "guides/server-notifications.md",
        "guides/signed-data-verification.md",
        "guides/error-handling.md",
        "guides/customizing-clients.md"
      ],
      groups_for_extras: [
        Guides: ~r"^guides/"
      ],
      groups_for_modules: [
        "Core Configuration": [
          AppStore,
          ~r"^AppStore.API.(Config|Response|Error)$"
        ],
        "API Client": [
          AppStore.API,
          ~r"^AppStore.API.(?!Config$|Response$|Error$)"
        ],
        "Signed Data & Notifications": [
          AppStore.ServerNotifications,
          ~r"^AppStore.SignedDataVerifier",
          AppStore.JWSValidation
        ],
        "Request Signing": [
          ~r"^AppStore.Token",
          ~r"^AppStore.SignatureCreator"
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
