# Hangman—The first iteration

We're going to be building increasingly sophisticated versions of a
Hangman game. This will let us explore Elixir syntax, libraries,
modules, processes, projects, and applications. We'll also use it as
the basis of our Phoenix programming.

In this first iteration we'll implement the code that runs the game.
This code selects a word to be guessed. It then accepts letters and
scores them against the target word, reporting the result.

The goal is to write this module without using any conditional
constructs: if, cond, or case. Instead, focus on writing reducers:
functions that transform state.

I've created a user interface to this code, so you'll be able to play
Hangman with your code.


## Where to Find Stuff

Although we haven't talked about this yet, I decided to use the
standard Elixir project structure for this application—it'll make it
easier as we go forward. Don't worry about it too much for now.

    .
    ├── README.md
    ├── assets
    │   ├── word lists . . .
    ├── config
    │   └── config.exs
    ├── lib
    │   ├── hangman
    │   │   ├── dictionary.ex
    │   │   ├── game.ex              ☜ your code goes here
    │   │   └── human_player.ex
    │   └── hangman.ex
    ├── mix.exs
    └── test
        ├── hangman_test.exs
        └── test_helper.exs


The source code is in the directory lib/hangman/. You'll be working in the
file `game.ex`. The documentation at the top of that file tells you what you
need todo.

## How to Run Stuff

Keep a shell open in this directory (the one holding the README.md file).

Although your editor will probably be able to do this, you can compile
your code from the command prompt using

     $ mix compile                   # this compiles files that changed

     $ mix do clean, compile         # this does a fresh compile

There are a suite of tests for the Game module. You can run them with

     $ mix test

(This will also compile your code.)

You can interact with your code using

     $ iex -S mix

This brings up mix with all the project's code preloaded. You can
call functions in your code using

     iex> Hangman.Game.«func(params)»

After your code is written, you can use the prewritten user interface:

    $  mix run -e Hangman.HumanPlayer.play


# The Game Module

Here's the documentation that's also included at the top of the Game module
(the module you'll be working on)


This is the backend for a Hangman game. It manages the game state.
Clients make moves, and this code validates them and reports back
the updated state.

Our API is

  * `game = Hangman.Game.new_game`
  * `{ game, status } = make_move(game, guess)`

and the auxiliary functions

  * `status = get_status(game)`
  * `{game, status} = reset_game(game)`
  
In this api, `game` is the opaque (internal) representation of the
state of play maintained by your module. `status` is the external
representation of that state, used by clients of your module. It tells
them thinks like the number of turns left, the word to be guessed with
the letters the client got right filled in, and so on.

Two functions, `make_move` and `reset_game`, can change the internal
state of the game. As a result, they return a new `game` value.

There's more documentation for each function inline in `lib/hangman/game.ex`

## Example of use

Here's this module being exercised from an iex session. For all but
the first line we only show the resulting status (not the value of the
`game` variable).

    iex> alias Hangman.Game
    Hangman.Game
    #
    iex> game = Game.new_game("wombat")
    #
    iex> { game, status } = Game.make_move(game, "a"); status
    %{game_state: :in_progress, guess_state: :good_guess, last_guess: "a",
      letters: ["_", "_", "_", "_", "a", "_"], turns_left: 10}
    #
    iex> { game, status } = Game.make_move(game, "b"); status
    %{game_state: :in_progress, guess_state: :good_guess, last_guess: "b",
      letters: ["_", "_", "_", "b", "a", "_"], turns_left: 10}
    #
    iex> { game, status } = Game.make_move(game, "c"); status
    %{game_state: :in_progress, guess_state: :bad_guess, last_guess: "c",
      letters: ["_", "_", "_", "b", "a", "_"], turns_left: 9}
    #
    iex> { game, status } = Game.make_move(game, "d"); status
    %{game_state: :in_progress, guess_state: :bad_guess, last_guess: "d",
      letters: ["_", "_", "_", "b", "a", "_"], turns_left: 8}
    #
    iex> { game, status } = Game.make_move(game, "a"); status
    %{game_state: :in_progress, guess_state: :already_guessed, last_guess: "a",
      letters: ["_", "_", "_", "b", "a", "_"], turns_left: 8}
    #
    iex> { game, status } = Game.make_move(game, "w"); status
    %{game_state: :in_progress, guess_state: :good_guess, last_guess: "w",
      letters: ["w", "_", "_", "b", "a", "_"], turns_left: 8}
    #
    iex> { game, status } = Game.make_move(game, "o"); status
    %{game_state: :in_progress, guess_state: :good_guess, last_guess: "o",
      letters: ["w", "o", "_", "b", "a", "_"], turns_left: 8}
    #
    iex> { game, status } = Game.make_move(game, "m"); status
    %{game_state: :in_progress, guess_state: :good_guess, last_guess: "m",
      letters: ["w", "o", "m", "b", "a", "_"], turns_left: 8}
    #
    iex> { _game, _status } = Game.make_move(game, "t"); status
    %{game_state: :won, guess_state: :good_guess, last_guess: "t",
      letters: ["w", "o", "m", "b", "a", "t"], turns_left: 8}

