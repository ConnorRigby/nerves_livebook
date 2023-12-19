defmodule NervesLivebook.MixProject do
  use Mix.Project

  @app :nerves_livebook
  @version "0.11.0"
  @source_url "https://github.com/nerves-livebook/nerves_livebook"

  @rpi_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4]
  @all_targets @rpi_targets ++
                 [:bbb, :osd32mp1, :x86_64, :npi_imx6ull, :grisp2, :mangopi_mq_pro, :srhub]

  # Libraries that use MMAL on the Raspberry Pi won't work with the Raspberry
  # Pi 4. The Raspberry Pi 4 uses DRM and libcamera.
  @rpi_mmal_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a]

  # See the BlueHeron repository for the boards that it supports.
  @ble_targets [:rpi0, :rpi3, :rpi3a]

  # Targets supporting cellular modems
  @cellular_targets [:srhub]

  # TFLite isn't building on the RPi and RPi0 (armv6), so just don't include it there.
  @tflite_targets @all_targets -- [:rpi, :rpi0]

  # Instruct the compiler to create deterministic builds to minimize
  # differences between firmware versions. This helps delta firmware update
  # compression.
  System.put_env("ERL_COMPILER_OPTIONS", "deterministic")

  def project do
    [
      app: @app,
      description: "Develop on embedded devices with Livebook and Nerves",
      author: "https://github.com/nerves-livebook/nerves_livebook/graphs/contributors",
      version: @version,
      package: package(),
      elixir: "~> 1.14",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host, "phx.server": :host],
      dialyzer: dialyzer(),
      docs: docs(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      }
    ]
  end

  def application do
    [
      mod: {NervesLivebook.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets, :ex_unit]
    ]
  end

  # The nice part about posting to hex is that documentation links work when you're
  # calling NervesLivebook functions.
  defp package do
    %{
      files: [
        "CHANGELOG.md",
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE",
        "assets",
        "priv"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    }
  end

  defp deps do
    [
      # Dependencies for host and target
      {:nerves, "~> 1.10", runtime: false},
      {:shoehorn, "~> 0.9.0"},
      {:ring_logger, "~> 0.9"},
      {:toolshed, "~> 0.3.0"},
      {:jason, "~> 1.2"},
      {:nerves_runtime, "~> 0.13.0"},
      {:livebook, "~> 0.11.0"},
      {:plug, "~> 1.12"},
      {:vintage_net, "~> 0.13"},

      # Pull in commonly used libraries as a convenience to users.
      {:blue_heron, "~> 0.4", targets: @ble_targets},
      {:blue_heron_transport_uart, "~> 0.1.4", targets: @ble_targets},
      {:bmp280, "~> 0.2", targets: @all_targets},
      {:circuits_gpio, "~> 1.0"},
      {:circuits_i2c, "~> 2.0 or ~> 1.0"},
      {:circuits_spi, "~> 2.0 or ~> 1.0"},
      {:circuits_uart, "~> 1.3"},
      {:delux, "~> 0.2"},
      {:hts221, "~> 1.0", targets: @all_targets},
      {:input_event, "~> 1.0 or ~> 0.4", targets: @all_targets},
      {:kino, "~> 0.7"},
      {:kino_vega_lite, "~> 0.1.1"},
      {:nerves_key, "~> 1.0", targets: @all_targets},
      {:nerves_pack, "~> 0.7.0", targets: @all_targets},
      {:nerves_time_zones, "~> 0.3.0", targets: @all_targets},
      {:nx, "~> 0.6.2"},
      {:phoenix_pubsub, "~> 2.0"},
      {:picam, "~> 0.4.0", targets: @rpi_mmal_targets},
      {:pigpiox, "~> 0.1", targets: @rpi_targets},
      {:pinout, "~> 0.1"},
      {:progress_bar, "~> 3.0"},
      {:ramoops_logger, "~> 0.1", targets: @all_targets},
      {:recon, "~> 2.5"},
      {:req, "~> 0.4.4"},
      {:scroll_hat, "~> 0.1", targets: @rpi_targets},
      {:stb_image, "~> 0.6.0"},
      {:tflite_elixir, "~> 0.3.4", targets: @tflite_targets},
      {:vega_lite, "~> 0.1"},
      {:vintage_net_mobile, "~> 0.11", targets: @cellular_targets},
      {:vintage_net_qmi, "~> 0.3", targets: @cellular_targets},

      # Nerves system dependencies
      {:nerves_system_rpi, "~> 1.25", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.25", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.25", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.25", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.25", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.25", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.17", runtime: false, targets: :bbb},
      {:nerves_system_osd32mp1, "~> 0.16", runtime: false, targets: :osd32mp1},
      {:nerves_system_x86_64, "~> 1.25", runtime: false, targets: :x86_64},
      {:nerves_system_npi_imx6ull, "~> 0.13", runtime: false, targets: :npi_imx6ull},
      {:nerves_system_grisp2, "~> 0.9", runtime: false, targets: :grisp2},
      {:nerves_system_mangopi_mq_pro, "~> 0.7", runtime: false, targets: :mangopi_mq_pro},
      {:nerves_system_srhub, "~> 0.27", runtime: false, targets: :srhub},

      # Compile-time only
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.3", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :docs, runtime: false},
      {:sbom, "~> 0.6", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      assets: "assets",
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  def release do
    [
      overwrite: true,
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: [keep: ["Docs"]]
    ]
  end

  defp dialyzer() do
    [
      flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling, :underspecs],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end
end
