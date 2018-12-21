defmodule Snipe.Ssh do
  require Snipe.Helpers, as: Helpers
  require Logger
  alias Snipe.Conn
  @moduledoc false

  defmodule Behaviour do
    @moduledoc false
    # a contract for ssh to fufil, for Mox
    @callback start() :: :ok | {:error, any()}
    @callback close_connection(Conn.t()) :: :ok | {:error, any()}
  end

  @behaviour __MODULE__.Behaviour

  # starts the erlang ssh application
  @impl true
  def start do
    case :ssh.start() do
      :ok -> Logger.info("SSH application started.")
      e -> Helpers.handle_error(e)
    end
  end

  # closes an ssh connection
  @impl true
  def close_connection(connection) do
    :ssh.close(connection.connection_ref)
  end
end
