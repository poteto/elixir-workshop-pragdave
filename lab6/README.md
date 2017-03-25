# Hangman, The Application

Time to wrap up the app.

We'll need to do a few things. First, we'll add supervision.

For this app, we have a dictionary, and we'll have a dynamic pool of
worker processes running the GameServer module. This means we'll need
two supervisors.

The top level supervisor will be written in the file `lib/hangman.ex`,
inside the `start/2` function. It will start the dictionary worker and
a second supervisor, Hangman.GameSupervisor.

You'll need to write a module for this second supervisor. It will use
the `simple_one_for_one` strategy to create and control a pool of
GameServers. Your supervisor module will provide a `start_link`
function to get itself started, and a `new_game` function that will
call the supervisor to ask it to spawn a new worked.

Once this part is done, you'll be able to use iex to get it running:

    iex> Hangman.start(nil, nil)
    
    iex> pid = Hangman.GameSupervisor.new_game
    
    iex> Hangman.GameServer.make_move("a") # ...
    
Finally, add the `mod:` section to the application function in
`mix.exs`. 

      mod:  { Hangman, [] },
    
Now when you run `iex -S mix`, everything should start automatically.

Verify that the game can still be played:

    $ mix run  -e Hangman.HumanPlayer.play

    $ mix run  -e Hangman.ComputerPlayer.play
    
    

     
