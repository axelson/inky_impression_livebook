defmodule NervesLivebook do
  @moduledoc """
  Nerves Livebook firmware
  """

  require Logger

  @doc """
  Return the mix target that was used to build this firmware

  This is useful for locating firmware updates and checking if you're
  running on non-Nerves device.
  """
  @spec target() :: atom()
  def target() do
    Application.get_env(:nerves_livebook, :target)
  end

  @doc """
  Return the Nerves Livebook version

  This returns the version as a string.
  """
  @spec version() :: String.t()
  def version() do
    Application.spec(:nerves_livebook, :vsn)
    |> to_string()
  end

  @doc """
  Convenience method for checking internet-connectivity for a Livebook
  """
  @spec check_internet!() :: :ok
  def check_internet!() do
    unless target() == :host or VintageNet.get(["connection"]) == :internet,
      do: raise("Please check that at least one network interface can reach the internet")

    :ok
  end

  def ssh_check_pass(_provided_username, provided_password) do
    correct_password = Application.get_env(:livebook, :password, "nerves")

    provided_password == to_charlist(correct_password)
  end

  def ssh_show_prompt(_peer, _username, _service) do
    msg = """
    https://github.com/livebook-dev/nerves_livebook

    ssh #{Node.self()} # Use password "nerves"
    """

    {'Nerves Livebook', to_charlist(msg), 'Password: ', false}
  end

  def ssh_check_pass(_username, _password) do
    # Don't try this at home!
    true
  end

  def ssh_show_prompt(_peer, 'livebook', _service) do
    msg = """
    https://github.com/livebook-dev/nerves_livebook

    Use password "nerves"
    """

    {'Nerves Livebook', to_charlist(msg), 'Password: ', false}
  end

  def ssh_show_prompt(_peer, username, _service) do
    msg = """
    https://github.com/livebook-dev/nerves_livebook

    Wrong username, should use username 'livebook' (received #{username})

    ssh #{Node.self()} # Use password "nerves"
    """

    {'Nerves Livebook', to_charlist(msg), 'Password: ', false}
  end

end
