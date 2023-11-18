defmodule FlyMachines.MixProject do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/ckreiling/fly_machines"

  def project do
    [
      app: :fly_machines,
      version: @version,
      elixir: "~> 1.15",
      source_url: @url,
      homepage_url: @url,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_ref: @url
      ]
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
      {:req, "~> 0.4"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
