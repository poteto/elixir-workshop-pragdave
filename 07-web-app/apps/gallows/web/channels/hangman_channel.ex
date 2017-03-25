defmodule Gallows.HangmanChannel do
  use Gallows.Web, :channel
  alias Hangman.GameServer, as: Game

  def join("hangman:game", _payload, socket) do
    {:ok, assign(socket, :game, Hangman.GameSupervisor.new_game) }
  end

  def handle_in("get_status", _, socket) do
    Game.get_status(socket.assigns.game)
    |> reply_with_status(socket)
  end

  def handle_in("guess", %{ "letter" => letter }, socket) do
    Game.make_move(socket.assigns.game, letter)
    |> reply_with_status(socket)
  end

  def handle_in("reset_game", _, socket) do
    Game.reset_game(socket.assigns.game)
    |> IO.inspect
    |> reply_with_status(socket)
  end

  defp reply_with_status(status, socket) do
    push socket, "status", status
    { :noreply, socket }
  end

end
