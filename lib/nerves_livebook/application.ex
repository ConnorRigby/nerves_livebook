defmodule NervesLivebook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    initialize_data_directory()
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
    livebook_path = "/data/livebooks"
    starters = Application.app_dir(:nerves_livebook, ["priv", "livebooks"])

    unless File.exists?(livebook_path) do
      _ = File.mkdir_p(livebook_path)
      _ = File.cp_r(starters, livebook_path)
      :ok
    end

    samples_path = Path.join(livebook_path, "samples")
    _ = File.rm(samples_path)
    _ = File.ln_s(starters, samples_path)

    :ok
  end
end