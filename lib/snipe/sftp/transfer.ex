defmodule Snipe.Sftp.Transfer do
  require Snipe.Helpers, as: Helpers
  alias Snipe.Conn

  @moduledoc """
  Provides functions relating to data transfer.
  """

  @sftp Application.get_env(:sftp_ex, :sftp_service, Snipe.Sftp)

  @doc """
  Similar to IO.each_binstream this returns a tuple with the data
  and the file handle if data is read from the server. If it reaches
  the end of the file then {:halt, handle} is returned where handle is
  the file handle
  """
  def each_binstream(connection, handle, byte_length) do
    case @sftp.read(connection, handle, byte_length) do
      :eof ->
        {:halt, handle}

      {:error, reason} ->
        raise IO.StreamError, reason: reason

      {:ok, data} ->
        {[data], handle}
    end
  end

  @doc """
  Writes data to a open file using the channel PID
  """
  @spec write(Conn.t(), any(), any()) :: :ok | {:error, any()}
  def write(connection, handle, data) do
    case @sftp.write(connection, handle, data) do
      :ok -> :ok
      e -> Helpers.handle_error(e)
    end
  end

  @doc """
  Writes a file to a remote path given a file, remote path, and connection.
  """
  @spec upload(Conn.t(), Path.t(), any()) :: :ok | {:error, any()}
  def upload(connection, remote_path, file_handle) do
    case @sftp.write_file(connection, remote_path, file_handle) do
      :ok -> :ok
      e -> Helpers.handle_error(e)
    end
  end

  @doc """
  Downloads a remote path
    {:ok, data} if successful, {:error, reason} if unsuccessful
  """
  @spec download(Conn.t(), Path.t()) :: {:ok | :error, any()}
  def download(connection, remote_path) do
    case @sftp.read_file_info(connection, remote_path) do
      {:ok, file_stat} ->
        case File.Stat.from_record(file_stat).type do
          :directory -> download_directory(connection, remote_path)
          :regular -> download_file(connection, remote_path)
          _ -> {:error, "Unsupported Operation"}
        end

      e ->
        Helpers.handle_error(e)
    end
  end

  defp download_file(connection, remote_path) do
    case @sftp.read_file(connection, remote_path) do
      {:ok, data} -> [data]
      e -> Helpers.handle_error(e)
    end
  end

  defp download_directory(connection, remote_path) do
    case @sftp.list_dir(connection, remote_path) do
      {:ok, filenames} -> Enum.map(filenames, &download_file(connection, &1))
      e -> Helpers.handle_error(e)
    end
  end
end
