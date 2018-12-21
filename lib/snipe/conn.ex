defmodule Snipe.Conn do
  require Snipe.Helpers, as: Helpers

  @moduledoc """
  Connection related utilities
  """

  defstruct channel_pid: nil, connection_ref: nil, host: nil, port: 22, opts: []

  @type t :: %__MODULE__{}

  @ssh Application.get_env(:snipe, :ssh_service, Snipe.Ssh)
  @sftp Application.get_env(:snipe, :sftp_service, Snipe.Sftp)

  @doc """
  Stops a SFTP channel and closes the SSH connection.
  """
  @spec disconnect(t()) :: :ok
  def disconnect(connection) do
    @sftp.stop_channel(connection)
    @ssh.close_connection(connection)
  end

  @doc """
  Creates an SFTP connection
  """
  @spec connect(charlist(), integer(), Keyword.t()) ::
          {:ok, t()} | {:error, any()}
  def connect(host, port, opts) do
    @ssh.start()

    case @sftp.start_channel(host, port, opts) do
      {:ok, channel_pid, connection_ref} ->
        {:ok,
         %__MODULE__{
           channel_pid: channel_pid,
           connection_ref: connection_ref,
           host: host,
           port: port,
           opts: opts
         }}

      e ->
        Helpers.handle_error(e)
    end
  end
end
