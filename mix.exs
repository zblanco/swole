defmodule Swole.MixProject do
  use Mix.Project

  def project do
    [
      app: :swole,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, ">= 1.0.0"},
      # {:phoenix, ">= 1.5.0", only: [:dev, :test], optional: true},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.28", only: :dev}
    ]
  end
end
