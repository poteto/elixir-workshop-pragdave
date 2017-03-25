defmodule Hangman.HumanPlayer do

  @doc """
  This is how you start an interactive game of Hangman. Call

      HumanPlayer.play

  and it will create a new game, show you the current state, and
  then interact with you as you make guesses.
  """

  alias Hangman.{Dictionary, Game}

  def play do
    Dictionary.start_link
    game = Game.new_game
    { game, Game.get_status(game) }
    |> get_next_move
  end


  defp get_next_move({ _game, %{ letters: letters, game_state: :won }}) do
    IO.puts "\nCONGRATULATIONS! The word was #{letters |> Enum.join}"
  end

  defp get_next_move({_game, %{ letters: letters, game_state: :lost }}) do
    clear_screen()
    IO.puts drawing(0)
    IO.puts "\nSorry, you lose. The word was: #{letters |> Enum.join}"
  end

  defp get_next_move({ game, state }) do
    draw_current_board(state)
    report_move_status(state)
    guess = get_guess(state)
    Game.make_move(game, guess)
    |> get_next_move
  end

  defp report_move_status(%{ guess_state: nil }) do
  end
  
  defp report_move_status(%{ guess_state: :good_guess, last_guess: guess}) do
    IO.puts "#{inspect guess} is indeed in the word!\n"
  end
  
  defp report_move_status(%{ guess_state: :bad_guess, last_guess: guess}) do
    IO.puts "Ouch! #{inspect guess} is not in the word!\n"
  end

  defp report_move_status(%{ guess_state: :already_guessed, last_guess: guess}) do
    IO.puts "You've already guessed #{inspect guess}.\n"
  end

  def get_guess(state = %{ guessed: guessed }) do
    if length(guessed) > 0 do
      IO.puts "Letters used so far: #{ guessed |> Enum.join(", ")}"
    end
    guess_until_valid(state)
  end

  def guess_until_valid(state) do
    guess = IO.gets("Next letter:   ") |> String.downcase |> String.trim

    cond do
      String.length(guess) != 1 ->
        IO.puts "please enter a single character"
        guess_until_valid(state)

      guess in state.guessed ->
        IO.puts "you already tried '#{guess}'"
        guess_until_valid(state)

      true ->
        guess
    end
  end

  def draw_current_board(state) do
    clear_screen()
    IO.puts drawing(state.turns_left)
    IO.puts "Word to guess: #{state.letters |> Enum.join(" ")}\n"
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
