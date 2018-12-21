defmodule Snipe.Sftp.Access do
  alias Snipe.Conn
  require Snipe.Helpers, as: Helpers
  require Logger
  @moduledoc "Functions for accessing files and directories"

  @sftp Application.get_env(:snipe, :sftp_service, Snipe.Sftp)

  @doc """
  Closes an open file
  """
  @spec close(Conn.t(), any()) :: :ok | {:error, any()}
  def close(connection, handle) do
    case @sftp.close(connection, handle) do
      :ok -> :ok
      e -> Helpers.handle_error(e)
    end
  end

  @doc """
  Stat a remote file
  """
  @spec file_info(Conn.t(), Path.t()) :: {:ok, File.Stat.t()} | {:error, any()}
  def file_info(connection, remote_path) do
    case @sftp.read_file_info(connection, remote_path) do
      {:ok, file_info} -> {:ok, File.Stat.from_record(file_info)}
      e -> Helpers.handle_error(e)
    end
  end

  @doc """
  Opens a file given a channel PID and path.
  """
  @spec open(Conn.t(), Path.t(), any()) :: {:ok | :error, any()}
  def open(connection, path, mode) do
    case file_info(connection, path) do
      {:ok, info} ->
        case info.type do
          :directory -> open_dir(connection, path)
          _ -> open_file(connection, path, mode)
        end

      e ->
        Helpers.handle_error(e)
    end
  end

  def open_file(connection, remote_path, mode) do
    @sftp.open(connection, remote_path, mode)
  end

  def open_dir(connection, remote_path) do
    case @sftp.open_directory(connection, remote_path) do
      {:ok, handle} -> {:ok, handle}
      e -> Helpers.handle_error(e)
    end
  end
end
