defmodule Snipe.Sftp do
  @moduledoc false

  alias Snipe.Conn

  defmodule Behaviour do
    @moduledoc false

    # yep, that's "creat" and not a typo
    # this list is given by the erlang ssh_sftp documentation
    @type mode :: :read | :write | :creat | :trunc | :append | :binary

    @callback start_channel(charlist(), integer(), Keyword.t()) ::
                {:ok, pid(), :ssh.connection_ref()} | {:error, any()}
    @callback stop_channel(Conn.t()) :: :ok
    @callback rename(Conn.t(), Path.t(), Path.t()) :: :ok | {:error, any()}
    @callback read_file_info(Conn.t(), Path.t()) ::
                {:ok, struct()} | {:error, any()}
    @callback list_dir(Conn.t(), Path.t()) ::
                {:ok, [charlist()]} | {:error, any()}
    @callback delete(Conn.t(), Path.t()) :: :ok | {:error, any()}
    @callback delete_directory(Conn.t(), Path.t()) :: :ok | {:error, any()}
    @callback make_directory(Conn.t(), Path.t()) :: :ok | {:error, any()}
    @callback close(Conn.t(), term()) :: :ok | {:error, any()}
    @callback open(Conn.t(), Path.t(), mode()) ::
                {:ok, term()} | {:error, any()}
    @callback open_directory(Conn.t(), Path.t()) ::
                {:ok, term()} | {:error, any()}
    @callback read(Conn.t(), term(), integer()) ::
                {:ok, binary()} | :eof | {:error, any()}
    @callback read_file(Conn.t(), Path.t()) :: {:ok, binary()} | {:error, any()}
    @callback write(Conn.t(), term(), iolist()) :: :ok | {:error, any()}
    @callback write_file(Conn.t(), Path.t(), iolist()) :: :ok | {:error, any()}
  end

  @behaviour __MODULE__.Behaviour

  # a wrapper around the erlang ssh_sftp library

  @impl true
  def start_channel(host, port, opts),
    do: :ssh_sftp.start_channel(host, port, opts)

  @impl true
  def stop_channel(conn), do: :ssh_sftp.stop_channel(conn.channel_pid)

  @impl true
  def rename(conn, old_name, new_name),
    do: :ssh_sftp.rename(conn.channel_pid, old_name, new_name)

  @impl true
  def read_file_info(conn, remote_path),
    do: :ssh_sftp.read_file_info(conn.channel_pid, remote_path)

  @impl true
  def list_dir(conn, remote_path),
    do: :ssh_sftp.list_dir(conn.channel_pid, remote_path)

  @impl true
  def delete(conn, file), do: :ssh_sftp.delete(conn.channel_pid, file)

  @impl true
  def delete_directory(conn, directory_path),
    do: :ssh_sftp.del_dir(conn.channel_pid, directory_path)

  @impl true
  def make_directory(conn, remote_path),
    do: :ssh_sftp.make_dir(conn.channel_pid, remote_path)

  @impl true
  def close(conn, handle), do: :ssh_sftp.close(conn.channel_pid, handle)

  @impl true
  def open(conn, remote_path, mode),
    do: :ssh_sftp.open(conn.channel_pid, remote_path, mode)

  @impl true
  def open_directory(conn, remote_path),
    do: :ssh_sftp.opendir(conn.channel_pid, remote_path)

  @impl true
  def read(conn, handle, byte_length),
    do: :ssh_sftp.read(conn.channel_pid, handle, byte_length)

  @impl true
  def read_file(conn, remote_path),
    do: :ssh_sftp.read_file(conn.channel_pid, remote_path)

  @impl true
  def write(conn, handle, data),
    do: :ssh_sftp.write(conn.channel_pid, handle, data)

  @impl true
  def write_file(conn, remote_path, data),
    do: :ssh_sftp.write_file(conn.channel_pid, remote_path, data)
end
