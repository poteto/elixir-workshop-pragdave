defmodule Hangman.Status do
  alias Hangman.Status
  defstruct game_state: :in_progress,
            guess_state: nil,
            turns_left: nil,
            letters: [],
            last_guess: nil,
            guessed: MapSet.new()

  def new(difficulty, word) do
    %Status{turns_left: difficulty, letters: word_to_letters(word)}
  end

  def update_state(%Status{} = status, :already_guessed), do:
    %Status{status | guess_state: :already_guessed}
  def update_state(%Status{} = status, :good_guess), do:
    %Status{status | guess_state: :good_guess}
  def update_state(%Status{} = status, :bad_guess), do:
    %Status{status | guess_state: :bad_guess}
  def update_state(%Status{}, _), do:
    :err

  def update_turns_left(%Status{turns_left: turns_left} = status, -1) do
    %Status{status | turns_left: turns_left - 1}
  end
  def update_turns_left(%Status{turns_left: turns_left} = status, 1) do
    %Status{status | turns_left: turns_left + 1}
  end

  def update_letters(%Status{letters: letters} = status, letter, word) do
    %Status{status | letters: reveal_word(word, letters, letter)}
  end

  def record_guess(%Status{guessed: guessed} = status, letter) do
    %Status{status | guessed: MapSet.put(guessed, letter), last_guess: letter}
  end

  def has_guessed(%Status{guessed: guessed} = status, letter, game) do
    case MapSet.member?(guessed, letter) do
      true -> {:err, game, :already_guessed}
      false -> :ok
    end
  end

  defp word_to_letters(word) do
    word
    |> String.replace(~r/./, "_")
    |> String.codepoints()
  end

  def reveal_word(word, letters, letter) do
    word
    |> String.codepoints()
    |> Enum.reduce(letters, fn c, acc ->
      {:ok, r} = Regex.compile("[^#{c}]")
      Regex.scan(r, word)
      |> List.flatten()
      |> Enum.map(fn _ -> "_" end)
      # TODO word revealing algorithm
    end)
  end
end
