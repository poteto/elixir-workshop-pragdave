defmodule Hangman.HumanPlayer do

  @doc """
  This is how you start an interactive game of Hangman. Call

      HumanPlayer.play

  and it will create a new game, show you the current state, and
  then interact with you as you make guesses.
  """

  alias Hangman.Game

  def play do
    state = Game.new_game
    get_next_move({state, :first_move, nil})
  end


  defp get_next_move({state, :won, nil}) do
    IO.puts "\nCONGRATULATIONS! The word was #{Game.word_as_string(state)}"
  end

  defp get_next_move({state, :lost, nil}) do
    clear_screen()
    IO.puts drawing(0)
    IO.puts "\nSorry, you lose. The word was: #{Game.word_as_string(state, true)}"
  end

  defp get_next_move({state, move_status, guess}) do
    draw_current_board(state)
    report_move_status(move_status, guess)
    guess = get_guess(state)
    Game.make_move(state, guess) |> get_next_move
  end

  defp report_move_status(ms, guess) do
    case ms do
      :good_guess -> IO.puts "#{inspect guess} is indeed in the word!\n"
      :bad_guess  -> IO.puts "Ouch! #{inspect guess} is not in the word!\n"
      _           -> nil
    end
  end

  def get_guess(state) do
    guessed = state |> Game.letters_used_so_far
    if length(guessed) > 0 do
      IO.puts "Letters used so far: #{ guessed |> Enum.join(", ")}"
    end
    guess_until_valid(state)
  end

  def guess_until_valid(state) do
    guess = IO.gets("Next letter:   ") |> String.downcase |> String.trim
    guessed = state |> Game.letters_used_so_far

    cond do
      String.length(guess) != 1 ->
        IO.puts "please enter a single character"
        guess_until_valid(state)

      guess in guessed ->
        IO.puts "you already tried '#{guess}'"
        guess_until_valid(state)

      true ->
        guess
    end
  end

  def draw_current_board(state) do
    clear_screen()
    IO.puts drawing(Game.turns_left(state))
    IO.puts "Word to guess: #{Game.word_as_string(state)}\n"
  end

  defp clear_screen(), do: IO.write "\e[H\e[2J"


  defp drawing(10) do
  """
  HANGMAN: Moves left 10






  ____________
  """
  end

  defp drawing(9) do
  """
  HANGMAN: Moves left 9




   ___
  |   |______
  |__________|
  """
  end

  defp drawing(8) do
  """
  HANGMAN: Moves left 8

    |
    |
    |
   _|_
  |   |______
  |__________|
  """
  end

  defp drawing(7) do
  """
  HANGMAN: Moves left 7
     ____
    |
    |
    |
    |
   _|_
  |   |______
  |__________|
  """
  end

  defp drawing(6) do
  """
  HANGMAN: Moves left 6
     ____
    |    |
    |
    |
    |
   _|_
  |   |______
  |__________|
  """
  end

  defp drawing(5) do
  """
  HANGMAN: Moves left 5
     ____
    |    |
    |    ⃝
    |
    |
   _|_
  |   |______
  |__________|
  """
  end

  defp drawing(4) do
  """
  HANGMAN: Moves left 4
     ____
    |    |
    |    ⃝
    |    |
    |    |
   _|_
  |   |______
  |__________|
  """
  end

  defp drawing(3) do
  """
  HANGMAN: Moves left 3
     ____
    |    |
    |    ⃝
    |   /|
    |    |
   _|_
  |   |______
  |__________|
  """
  end

  defp drawing(2) do
  """
  HANGMAN: Moves left 2
     ____
    |    |
    |    ⃝
    |   /|\\
    |    |
   _|_
  |   |______
  |__________|
  """
  end

  defp drawing(1) do
  """
  HANGMAN: Moves left 1
     ____
    |    |
    |    ⃝
    |   /|\\
    |    |
   _|_  /
  |   |______
  |__________|
  """
  end

  defp drawing(0) do
  """
  HANGMAN   :(
     ____
    |    |
    |    ⊗
    |   /|\\
    |    |
   _|_  / \\
  | * |______
  |__________|
  """
  end

end
