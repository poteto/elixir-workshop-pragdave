defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  #  doctest Game

  describe "a new game" do

    setup do
      [ game: Game.new_game("wibble") ]
    end

    test "has a reasonable status", c do
      status = Game.get_status(c.game)
      assert status.game_state == :in_progress
      assert status.turns_left == 10
      assert status.letters    == ~w{ _ _ _ _ _ _ }
    end
  end

  describe "guess a good letter" do
    setup do
      { _, status } = Game.new_game("wibble") |> Game.make_move("b")
      [ status: status  ]
    end

    test "returns the correct status", c do
      assert c.status.game_state  == :in_progress
      assert c.status.guess_state == :good_guess
      assert c.status.last_guess  == "b"
      assert c.status.turns_left == 10
      assert c.status.letters    == ~w{ _ _ b b _ _ }
    end
  end

  describe "guess a bad letter" do
    setup do
      { _, status } = Game.new_game("wibble") |> Game.make_move("a")
      [ status: status ]
    end

    test "returns the correct status", c do
      assert c.status.game_state  == :in_progress
      assert c.status.guess_state == :bad_guess
      assert c.status.last_guess  == "a"
      assert c.status.turns_left  == 9
      assert c.status.letters     == ~w{ _ _ _ _ _ _ }
    end
  end

  test "playing a winning game" do

    moves = [
      %{ guess: "a", game_state: :in_progress, guess_state: :bad_guess,  turns_left: 9, letters: ~w{ _ _ _ _ _ _ } },
      %{ guess: "b", game_state: :in_progress, guess_state: :good_guess, turns_left: 9, letters: ~w{ _ _ b b _ _ } },
      %{ guess: "x", game_state: :in_progress, guess_state: :bad_guess,  turns_left: 8, letters: ~w{ _ _ b b _ _ } },
      %{ guess: "w", game_state: :in_progress, guess_state: :good_guess, turns_left: 8, letters: ~w{ w _ b b _ _ } },
      %{ guess: "i", game_state: :in_progress, guess_state: :good_guess, turns_left: 8, letters: ~w{ w i b b _ _ } },
      %{ guess: "l", game_state: :in_progress, guess_state: :good_guess, turns_left: 8, letters: ~w{ w i b b l _ } },
      %{ guess: "q", game_state: :in_progress, guess_state: :bad_guess,  turns_left: 7, letters: ~w{ w i b b l _ } },
      %{ guess: "e", game_state: :won,         guess_state: :good_guess, turns_left: 7, letters: ~w{ w i b b l e } },
    ]

    test_moves(moves)
  end

  test "playing a losing game" do

    moves = [
      %{ guess: "a", game_state: :in_progress, guess_state: :bad_guess,        turns_left: 9, letters: ~w{ _ _ _ _ _ _ } },
      %{ guess: "b", game_state: :in_progress, guess_state: :good_guess,       turns_left: 9, letters: ~w{ _ _ b b _ _ } },
      %{ guess: "x", game_state: :in_progress, guess_state: :bad_guess,        turns_left: 8, letters: ~w{ _ _ b b _ _ } },
      %{ guess: "w", game_state: :in_progress, guess_state: :good_guess,       turns_left: 8, letters: ~w{ w _ b b _ _ } },
      %{ guess: "i", game_state: :in_progress, guess_state: :good_guess,       turns_left: 8, letters: ~w{ w i b b _ _ } },
      %{ guess: "l", game_state: :in_progress, guess_state: :good_guess,       turns_left: 8, letters: ~w{ w i b b l _ } },
      %{ guess: "q", game_state: :in_progress, guess_state: :bad_guess,        turns_left: 7, letters: ~w{ w i b b l _ } },
      %{ guess: "q", game_state: :in_progress, guess_state: :already_guessed,  turns_left: 7, letters: ~w{ w i b b l _ } },
      %{ guess: "r", game_state: :in_progress, guess_state: :bad_guess,        turns_left: 6, letters: ~w{ w i b b l _ } },
      %{ guess: "t", game_state: :in_progress, guess_state: :bad_guess,        turns_left: 5, letters: ~w{ w i b b l _ } },
      %{ guess: "y", game_state: :in_progress, guess_state: :bad_guess,        turns_left: 4, letters: ~w{ w i b b l _ } },
      %{ guess: "u", game_state: :in_progress, guess_state: :bad_guess,        turns_left: 3, letters: ~w{ w i b b l _ } },
      %{ guess: "o", game_state: :in_progress, guess_state: :bad_guess,        turns_left: 2, letters: ~w{ w i b b l _ } },
      %{ guess: "p", game_state: :in_progress, guess_state: :bad_guess,        turns_left: 1, letters: ~w{ w i b b l _ } },
      %{ guess: "s", game_state: :lost,        guess_state: :bad_guess,        turns_left: 0, letters: ~w{ w i b b l e } },
    ]

    test_moves(moves)
  end

  defp test_moves(moves) do
    game = Game.new_game("wibble")

    Enum.reduce(moves, game, fn (move, game) ->
      {game, status} = Game.make_move(game, move.guess)
      assert status.game_state  == move.game_state
      assert status.guess_state == move.guess_state
      assert status.last_guess  == move.guess
      assert status.turns_left  == move.turns_left
      assert status.letters     == move.letters
      game
    end)
  end

end
