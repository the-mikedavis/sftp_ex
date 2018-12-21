defmodule Snipe do
  @moduledoc """
  Functions for transferring and managing files through SFTP
  """
  alias Snipe.Sftp.{Access, Management, Transfer, Stream}

  alias Snipe.Conn, as: Conn

  @default_opts [
    user_interaction: false,
    silently_accept_hosts: true,
    rekey_limit: 1_000_000_000_000,
    port: 22
  ]

  @doc """
  Download a file given the connection and remote_path
  Returns {:ok, data}, {:error, reason}
  """
  @spec download(Conn.t(), Path.t()) :: {:ok | :error, any()}
  def download(connection, remote_path) do
    Transfer.download(connection, remote_path)
  end

  @doc """
  Upload a local file to a remote path
  Returns :ok, or {:error, reason}
  """
  @spec upload(Conn.t(), Path.t(), Path.t()) :: :ok | {:error, any()}
  def upload(connection, remote_path, file_handle) do
    Transfer.upload(connection, remote_path, file_handle)
  end

  @doc """
  Creates a Connection struct if the connection is successful,
  else will return {:error, reason}

  A connection struct will contain the
    channel_pid = pid()
    connection_pid = pid()
    host = string()
    port = integer()
    opts = [{Option, Value}]

  Default values are set for the following options:

  user_interaction: false,
  silently_accept_hosts: true,
  rekey_limit: 1000000000000,
  port: 22

  ***NOTE: The only required option is ':host'

  The rekey_limit value is set at a large amount because the Erlang library creates
  an exception when the server is negotiating a rekey. Setting the value at a high number
  of bytes will avoid a rekey event occurring.

  Other available options can be found at http://erlang.org/doc/man/ssh.html#connect-3
  """
  @spec connect(Keyword.t()) :: {:ok, Conn.t()} | {:error, any()}
  def connect(opts) do
    opts = @default_opts |> Keyword.merge(opts)
    own_keys = [:host, :port]
    ssh_opts = opts |> Enum.filter(fn {k, _} -> not (k in own_keys) end)
    Conn.connect(opts[:host], opts[:port], ssh_opts)
  end

  @doc """
  Open a connection.

  If the connection does not succeed, raises an error.
  """
  @spec connect!(Keyword.t()) :: Conn.t()
  def connect!(opts) do
    case connect(opts) do
      {:ok, conn} -> conn
      {:error, reason} -> raise reason
    end
  end

  @doc """
  Creates an SFTP stream by opening an SFTP connection and opening a file
  in read or write mode.

  Below is an example of reading a file from a server.

  An example of writing a file to a server is the following.

  stream = File.stream!("filename.txt")
      |> Stream.into(Snipe.stream!(connection,"/home/path/filename.txt"))
      |> Stream.run

  This follows the same pattern as Elixir IO streams so a file can be transferred
  from one server to another via SFTP as follows.

  stream = Snipe.stream!(connection,"/home/path/filename.txt")
  |> Stream.into(Snipe.stream!(connection2,"/home/path/filename.txt"))
  |> Stream.run
  """
  @spec stream!(Conn.t(), Path.t(), non_neg_integer()) :: Stream.t()
  def stream!(connection, remote_path, byte_size \\ 32768) do
    %Stream{
      connection: connection,
      path: remote_path,
      byte_length: byte_size
    }
  end

  @doc """
  Opens a file or directory given a connection and remote_path
  """
  @spec open(Conn.t(), Path.t()) :: {:ok | :error, any()}
  def open(connection, remote_path) do
    Access.open(connection, remote_path, :read)
  end

  @doc """
  Lists the contents of a directory given a connection a handle or remote path
  """
  @spec ls(Conn.t(), Path.t()) :: {:ok, [Path.t()]} | {:error, any()}
  def ls(connection, remote_path) do
    Management.list_files(connection, remote_path)
  end

  @doc """
  Lists the contents of a directory given a connection a handle or remote path
  """
  @spec mkdir(Conn.t(), Path.t()) :: :ok | {:error, any()}
  def mkdir(connection, remote_path) do
    Management.make_directory(connection, remote_path)
  end

  @doc """
  Stat a file.
  """
  def lstat(connection, remote_path) do
    Access.file_info(connection, remote_path)
  end

  @doc """
  Determine the size of a file
  """
  def size(connection, remote_path) do
    case Access.file_info(connection, remote_path) do
      {:error, reason} -> {:error, reason}
      {:ok, info} -> info.size
    end
  end

  @doc """
  Gets the type given a remote path.
  """
  def get_type(connection, remote_path) do
    case Access.file_info(connection, remote_path) do
      {:error, reason} -> {:error, reason}
      {:ok, info} -> info.type
    end
  end

  @doc """
  Stops the SSH application
  """
  def disconnect(connection) do
    Conn.disconnect(connection)
  end

  @doc """
  Removes a file from the server.
  """
  def rm(connection, file) do
    Management.remove_file(connection, file)
  end

  @doc """
  Removes a directory and all files within it
  """
  def rm_dir(connection, remote_path) do
    Management.remove_directory(connection, remote_path)
  end

  @doc """
  Renames a file or directory
  """
  def rename(connection, old_name, new_name) do
    Management.rename(connection, old_name, new_name)
  end
end
