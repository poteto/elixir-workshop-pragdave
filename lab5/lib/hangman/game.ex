defmodule Hangman.Game do

  @moduledoc """

  This is the backend for a Hangman game. It manages the game state.
  Clients make moves, and this code validates them and reports back
  the updated state.

  Our API is

  * `game = Hangman.Game.new_game`
  * `{game, status, guess} = make_move(game, guess)`

  and the auxiliary functions

  * `status = get_status(game)`
  * `{game, status} = reset_game(game)`


## Example of use

Here's this module being exercised from an iex session. For all but
the first line we only show the resulting status (not the value of the
`game` variable).

    iex> alias Hangman.Game
    Hangman.Game
    #
    iex> { game, _initial_state } = Game.new_game("wombat"); game
    %{game_state: :in_progress, guess_state: nil, guessed: #MapSet<[]>,
      last_guess: nil, turns_left: 10,
      word: [{"w", false}, {"o", false}, {"m", false}, {"b", false}, {"a", false},
       {"t", false}]}
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
  """


  @type game   :: map
  @type status :: map
  @type ch     :: String.t
  @type optional_ch :: ch | nil

  @doc """
    Set up the state for a new game, and return that state. The client
    applications will pass this state back to your code in all the
    subsequent API calls.

        `game = Hangman.Game.new_game()`

    The `game` that's returned is an opaque structure used internally
    by this module. You'll likely want to use a map.

    As an aid to testing, there's a second form of this function:

        `{ game, status } = Hangman.Game.new_game(word)`

    This forces `word` to be this game's hidden word.
  """

  @spec new_game(String.t) :: game
  
  def new_game(word \\ Hangman.Dictionary.random_word) do
    %{
      word:        String.codepoints(word) |> Enum.map(&{&1, false}),
      turns_left:  10,
      guessed:     MapSet.new,
      last_guess:  nil,
      game_state:  :in_progress,   # or :won or :lost
      guess_state: nil,            # :good_guess or :bad_guess
    }
  end

  @doc """

  `{game, status} = make_move(game, guess)`

   Accept a guess. Return a tuple containing the updated
   game state and a map containing the game's status at the end of the move.


         last_guess:  # the last character guessed
         game_state:  # :in_progress, :lost, or :won
         guess_state: # :good_guess, :bad_guess, or :already_guessed
         turns_left:  # the number of turns remaining
         guessed:     # a list of the letters already guessed
         letters:     # a list of single character strings representing
                      # the word to guess. Letters in the word that have
                      # been previously guessed correctly are shown as
                      # themselves. Letters that still have to be
                      # guessed are shown as underscores.
  """

  @spec make_move(game, ch) :: { game, status }
  
  def make_move(game, guess) do
    already_guessed = MapSet.member?(game.guessed, guess)
    make_move_if_not_already_guessed(game, guess, already_guessed)
    |> return_game_and_public_status()
  end

  @doc """
  Return the status of game. See `make_move` for the format.
  """
  @spec get_status(game) :: status
  def get_status(game) do
    public_status(game)
  end

  
  @doc """
  Return a fresh game, discarding the previous state of `game`
  """
  @spec reset_game(game) :: game
  def reset_game(_game) do
    new_game()
    |> return_game_and_public_status()
  end


  ###########################
  # end of public interface #
  ###########################

  defp make_move_if_not_already_guessed(game, _guess, true) do
    already_guessed(game)
  end

  defp make_move_if_not_already_guessed(game, guess, false) do
    game
    |> record_move(guess)
    |> score_move()
  end


  defp record_move(game, guess) do
    %{ game | last_guess: guess, guessed: MapSet.put(game.guessed, guess) }
  end    

  defp score_move(game = %{ turns_left: 0 }) do
    %{ game | game_state: :lost,  guess_state: :bad_guess }
  end

  defp score_move(game) do
    case word_contains_guess?(game.word, game.last_guess) do
      nil ->
        bad_guess(game)
      _ ->
        good_guess(game)
    end
  end

  defp good_guess(game = %{ last_guess: guess, word: word }) do
    new_word = update_word_with_guess(word, guess)
    won      = player_won_status(new_word)
    %{ game | word: new_word, guess_state: :good_guess, game_state: won }
  end

  defp already_guessed(game) do
    %{ game | guess_state: :already_guessed }
  end

  defp bad_guess(game = %{ turns_left: turns_left }) when turns_left > 1 do
    %{ game | guess_state: :bad_guess, turns_left: turns_left - 1 }
  end

  defp bad_guess(game) do
    %{ game | guess_state: :bad_guess, game_state: :lost, turns_left: 0 }
  end
  


  defp update_word_with_guess(word, guess) do
    Enum.map(word, fn
      { ^guess, _ } -> { guess, true }
      other         -> other
    end)
  end

  defp word_contains_guess?(word, guess) do
    Enum.find(word, fn { ch, _ } -> ch == guess end)
  end

  defp player_won_status(word) do
    player_won?(word)
    |> won_boolean_to_status
  end

  defp player_won?(word) do
    Enum.all?(word, fn {_ch, ok } -> ok end)
  end

  defp won_boolean_to_status(true),  do: :won
  defp won_boolean_to_status(false), do: :in_progress

  
  defp return_game_and_public_status(game) do
    { game, public_status(game) }
  end

  defp public_status(game) do
    %{
      last_guess:  game.last_guess,
      game_state:  game.game_state,
      guess_state: game.guess_state,
      turns_left:  game.turns_left,
      guessed:     game.guessed |> Enum.into([]),
      letters:     word_letters(game)
    }
  end

  defp word_letters(%{ game_state: game_state, word: word })
  when game_state in [:won, :lost] do
    word |> Enum.map(fn {letter, _} -> letter end)
  end

  defp word_letters(game) do    
    placeholder = fn
      { ch, true } -> ch
      _            -> "_"
    end
    game.word |> Enum.map(placeholder)
  end

end
