defmodule Snipe.Sftp.Stream do
  @moduledoc false
  alias Snipe.Sftp.{Access, Transfer}

  defstruct connection: nil, path: nil, byte_length: 32768

  @type t :: %__MODULE__{}

  defimpl Collectable do
    def into(%{connection: connection, path: path} = stream) do
      case Access.open_file(connection, path, [:write, :binary, :creat]) do
        {:ok, handle} -> {:ok, into(connection, handle, stream)}
        e -> e
      end
    end

    defp into(connection, handle, stream) do
      fn
        :ok, {:cont, x} ->
          Transfer.write(connection, handle, x)

        :ok, :done ->
          :ok = Access.close(connection, handle)
          stream

        :ok, :halt ->
          :ok = Access.close(connection, handle)
      end
    end
  end

  defimpl Enumerable do
    def reduce(
          %{connection: connection, path: path, byte_length: byte_length},
          acc,
          fun
        ) do
      start_function = fn ->
        case Access.open(connection, path, [:read, :binary]) do
          {:error, reason} ->
            raise File.Error, reason: reason, action: "stream", path: path

          {:ok, handle} ->
            handle
        end
      end

      next_function = &Transfer.each_binstream(connection, &1, byte_length)

      close_function = &Access.close(connection, &1)

      Stream.resource(start_function, next_function, close_function).(acc, fun)
    end

    def slice(_steram) do
      {:error, __MODULE__}
    end

    def count(_stream) do
      {:error, __MODULE__}
    end

    def member?(_stream, _term) do
      {:error, __MODULE__}
    end
  end
end
