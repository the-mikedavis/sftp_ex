# Snipe

An Elixir wrapper around the Erlang SFTP application. This allows for the use
of Elixir Streams to transfer files via SFTP. Forked from `mikejdorm/sftp_ex`.

## Creating a Connection

The following is an example of creating a connection with a username and
password.

```elixir
{:ok, conn} = SftpEx.connect([host: 'somehost', user: 'someuser', password: 'somepassword'])
```

Other connection arguments can be found in the [Erlang
documentation]("http://erlang.org/doc/man/ssh.html#connect-3").


## Streaming Files

An example of writing a file to a server is the following.

```elixir
stream = File.stream!("filename.txt")
    |> Stream.into(SftpEx.stream!(connection,"/home/path/filename.txt"))
    |> Stream.run
```

A file can be copied from remote to local as follows.

```elixir
SftpEx.stream!(connection,"test2.csv") |> Stream.into(File.stream!("filename.txt")) |> Stream.run
```

This follows the same pattern as Elixir IO streams so a file can be transferred
from one server to another via SFTP as follows.

```elixir
stream = SftpEx.stream!(connection,"/home/path/filename.txt")
|> Stream.into(SftpEx.stream!(connection2,"/home/path/filename.txt"))
|> Stream.run
```

## Installation

1. Add `sftp_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:sftp_ex, git: "git@github.com:the-mikedavis/sftp_ex.git"}]
end
```
