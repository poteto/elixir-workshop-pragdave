defmodule Gallows.UserSocket do
  use Phoenix.Socket

  channel "hangman:*", Gallows.HangmanChannel

  transport :websocket, Phoenix.Transports.WebSocket
  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
