defmodule Snipe.Helpers do
  require Logger

  @moduledoc false

  def handle_error(e) do
    Logger.error("#{inspect(e)}")
    e
  end
end
