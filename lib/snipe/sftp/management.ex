defmodule Snipe.Sftp.Management do
  require Snipe.Helpers, as: Helpers
  require Logger
  alias Snipe.Conn
  alias Snipe.Sftp.Access
  @sftp Application.get_env(:sftp_ex, :sftp_service, Snipe.Sftp)

  @moduledoc """
  Provides methods for managing files through an SFTP connection
  """

  @spec make_directory(Conn.t(), Path.t()) :: :ok | {:error, any()}
  def make_directory(connection, remote_path) do
    case @sftp.make_directory(connection, remote_path) do
      :ok -> :ok
      e -> Helpers.handle_error(e)
    end
  end

  @doc """
  Removes a directory and all files within the directory
  """
  @spec remove_directory(Conn.t(), Path.t()) :: :ok | {:error, any()}
  def remove_directory(connection, directory) do
    remove_all_files(connection, directory)

    @sftp.delete_directory(connection, directory)
  end

  @doc """
  Removes a file
  """
  @spec remove_file(Conn.t(), Path.t()) :: :ok | {:error, any()}
  def remove_file(connection, file), do: @sftp.delete(connection, file)

  @doc """
  Lists files in a directory
  """
  @spec list_files(Conn.t(), Path.t()) :: {:ok, [Path.t()]} | {:error, any()}
  def list_files(connection, remote_path) do
    with {:ok, file_info} <- Access.file_info(connection, remote_path),
         :directory <- file_info.type,
         {:ok, file_list} <- @sftp.list_dir(connection, remote_path),
         filtered_files <- Enum.reject(file_list, &dotted?/1) do
      {:ok, filtered_files}
    else
      {:error, _reason} = e -> Helpers.handle_error(e)
      _ -> {:error, "Remote path is not a directory!"}
    end
  end

  @spec dotted?(charlist()) :: boolean()
  defp dotted?('.'), do: true
  defp dotted?('..'), do: true
  defp dotted?(_), do: false

  @doc """
  Renames a file or directory
  """
  @spec rename(Conn.t(), Path.t(), Path.t()) :: {:ok | :error, any()}
  def rename(connection, old_name, new_name) do
    @sftp.rename(connection, old_name, new_name)
  end

  defp remove_all_files(connection, directory) do
    case list_files(connection, directory) do
      {:ok, filenames} -> Enum.each(filenames, remove_file(connection, & &1))
      e -> Helpers.handle_error(e)
    end
  end
end
