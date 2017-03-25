defmodule Hangman.GameServer do

  alias Hangman.Game, as: Impl

  use GenServer

  def start_link(word \\ Hangman.Dictionary.random_word) do
    GenServer.start_link(__MODULE__, word)
  end

  def make_move(pid, guess) do
    GenServer.call(pid, { :make_move, guess })
  end

  def get_status(pid) do
    GenServer.call(pid, { :get_status })
  end

  def reset_game(pid) do
    GenServer.call(pid, { :reset_game })
  end

  # used for testing

  def crash(pid, :normal) do
    if Process.whereis(pid), do: GenServer.stop(pid)
  end

  def crash(pid, reason) do
    GenServer.cast(pid, { :crash, reason })
  end
  
  ###########################
  # end of public interface #
  ###########################


  def init(word) do
    { :ok, Impl.new_game(word) }
  end

  def handle_call({ :make_move, guess }, _from, game) do
    { game, result } = Impl.make_move(game, guess)
    { :reply, result, game }
  end

  def handle_call({ :get_status }, _from, game) do
    status = Impl.get_status(game)
    { :reply, status, game }
  end

  def handle_call({ :reset_game }, _from, game) do
    { game, status } = Impl.reset_game(game)
    { :reply, status, game }
  end

  # used for testing

  def handle_cast({ :crash, reason }, game) do
    { :stop, reason, game }
  end


end
