defmodule Hangman do

  def start(_type, _args) do
    # this is where you'll start the top-level supervisor. it will have
    # the dictionary as a worker, and the GameSupervisor as a
    # subsupervisor. (You'll need to write the GameSupervisor)

    import Supervisor.Spec

    children = [
      # add the worker spec for the Dictionary, and
      # the supervisor spec for the game supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
  
end

