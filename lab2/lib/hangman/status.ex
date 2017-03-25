defmodule Hangman.Status do
  defstruct game_state: :in_progress,
            guess_state: nil,
            turns_left: @difficulty,
            letters: [],
            last_guess: nil,
            guessed: []

  def new(difficulty, word) do
    %Hangman.Status{turns_left: difficulty, letters: word_to_letters(word)}
  end

  defp word_to_letters(word) do
    word
    |> String.replace(~r/./, "_")
    |> String.codepoints()
  end
end

