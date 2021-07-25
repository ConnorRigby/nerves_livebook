defmodule NervesLivebook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    initialize_data_directory()
    setup_wifi()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NervesLivebook.Supervisor]

    children = [
      # Children for all targets
      # Starts a worker by calling: NervesLivebook.Worker.start_link(arg)
      # {NervesLivebook.Worker, arg},
    ]

    Supervisor.start_link(children, opts)
  end

  defp initialize_data_directory() do
    destination_dir = "/data/livebooks"
    source_dir = Application.app_dir(:nerves_livebook, "priv")

    # Best effort create everything
    _ = File.mkdir_p(destination_dir)
    Enum.each(["welcome.livemd", "samples"], &symlink(source_dir, destination_dir, &1))
  end

  defp symlink(source_dir, destination_dir, filename) do
    source = Path.join(source_dir, filename)
    dest = Path.join(destination_dir, filename)

    _ = File.rm(dest)
    _ = File.ln_s(source, dest)
  end

  defp setup_wifi() do
    kv = Nerves.Runtime.KV.get_all()

    if true?(kv["wifi_force"]) or VintageNet.get_configuration("wlan0") == %{type: VintageNetWiFi} do
      _ = VintageNetWiFi.quick_configure(kv["wifi_ssid"], kv["wifi_passphrase"])
      :ok
    end
  end

  defp true?(""), do: false
  defp true?(nil), do: false
  defp true?("false"), do: false
  defp true?("FALSE"), do: false
  defp true?(_), do: true
end
