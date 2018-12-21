defmodule SFTP.Connection do
  @moduledoc false
  defstruct channel_pid: nil, connection_ref: nil, host: nil, port: 22, opts: []

  @type t :: %__MODULE__{}
end
