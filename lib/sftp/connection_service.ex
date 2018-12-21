defmodule SFTP.ConnectionService do
  require SftpEx.Helpers, as: S

  @moduledoc """
  Provides methods related to starting and stopping an SFTP connection
  """
  @ssh Application.get_env(:sftp_ex, :ssh_service, SSH.Service)
  @sftp Application.get_env(:sftp_ex, :sftp_service, SFTP.Service)

  @doc """
  Stops a SFTP channel and closes the SSH connection.
  """
  @spec disconnect(SFTP.Connection.t()) :: :ok
  def disconnect(connection) do
    @sftp.stop_channel(connection)
    @ssh.close_connection(connection)
  end

  @doc """
  Creates an SFTP connection
  """
  @spec connect(charlist(), integer(), Keyword.t()) ::
          {:ok, SFTP.Connection.t()} | {:error, any()}
  def connect(host, port, opts) do
    @ssh.start()

    case @sftp.start_channel(host, port, opts) do
      {:ok, channel_pid, connection_ref} ->
        {:ok,
         %SFTP.Connection{
           channel_pid: channel_pid,
           connection_ref: connection_ref,
           host: host,
           port: port,
           opts: opts
         }}

      e ->
        S.handle_error(e)
    end
  end
end
