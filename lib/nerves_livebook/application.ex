defmodule NervesLivebook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    Nerves.Runtime.validate_firmware()
    initialize_data_directory()

    if target() != :host do
      # setup_wifi()
      add_mix_install()
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NervesLivebook.Supervisor]

    ui_options = Application.get_env(:nerves_livebook, :ui, [])

    children = [
      {NervesLivebook.UI, ui_options}
    ]

    Supervisor.start_link(children, opts)
  end

  defp initialize_data_directory() do
    destination_dir = "/data/livebook"
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

  defp add_mix_install() do
    # This needs to be done this way since redefining Mix at compile time
    # doesn't make anyone happy.
    _ =
      Code.eval_string("""
      defmodule Mix do
        def install(deps, opts \\\\ []) when is_list(deps) and is_list(opts) do
          NervesLivebook.MixInstall.install(deps, opts)
        end
      end
      """)

    :ok
  end

  defp target() do
    Application.get_env(:nerves_livebook, :target)
  end
end
