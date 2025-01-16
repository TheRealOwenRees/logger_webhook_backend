defmodule LoggerWebhookBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :logger_webhook_backend,
      version: "0.0.4",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/therealowenrees/logger_webhook_backend"
    ]
  end

  defp description do
    "A Logger backend that sends logs to a webhook."
  end

  defp package do
    [
      maintainers: ["Owen Rees"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/therealowenrees/logger_webhook_backend"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    test_apps = if Mix.env() == :test, do: [:logger, :inets, :ssl], else: []

    [
      extra_applications: [] ++ test_apps
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bypass, "~> 2.1", only: :test},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:jason, "~> 1.4"},
      {:logger_backends, "~> 1.0", only: :test},
      {:plug_cowboy, "~> 2.0", only: :test}
    ]
  end
end
