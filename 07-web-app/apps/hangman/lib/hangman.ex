defmodule Hangman do
  use Application

  @moduledoc """
  Our constraints are:

  * If the Game exits normally, do nothing. If it crashes,
    restart it (and just it).

  * If the Dictionary exits for any reason, kill any game,
    and restart both the Dictionary and the Game.

  We have a top-level supervisor that monitors the dictionary and
  a second level supervisor.

  The second level supervisor monitors a game server, restarting it
  if it stops abnormally.

  We use the `one_for_all` strategy, so he top level supervisor
  restarts everything if either of its children quits. The game
  supervisor uses `one_for_one`
   """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    IO.puts "STARTING"
    children = [
      worker(Hangman.Dictionary, []),
      supervisor(Hangman.GameSupervisor, [], [])
    ]

    opts = [strategy: :one_for_all, name: Hangman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

