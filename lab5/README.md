# Hangman—Making the Game a GenServer

We're going to create a GenServer to run the code in `game.ex`.

It's going to be a delegating server, so we won't be making any
changes inb `game.ex`. Instead, we're going to be writing a new
module, `lib/game_server.ex`, which delegates to the original game.

We're going to do this the traditional way, by writing the actual
GenServer code. To make it a little easier, I've already provided a
skeleton.

Once done, you'll be able to run this in IEx using

    iex> Hangman.Dictionary.start_link
    
    iex> alias Hangman.GameServer, as: GS
    
    iex> { :ok, pid } = GS.start_link
    
    iex> GS.make_move("a")
    
    . . .
    
    
