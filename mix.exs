defmodule Snipe.Mixfile do
  use Mix.Project

  def project do
    [
      app: :snipe,
      version: "0.2.6",
      elixir: ">= 1.3.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A powerful SFTP Elixir library",
      package: package(),
      # docs
      name: "snipe",
      source_url: "https://github.com/the-mikedavis/snipe",
      # The main page in the docs
      docs: [main: "Snipe", extras: ["README.md"]]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [applications: [:logger, :ssh, :public_key, :crypto]]
  end

  defp deps do
    [
      {:mox, "~> 0.4.0", only: :test},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Michael Davis"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/the-mikedavis/snipe"}
    ]
  end
end
