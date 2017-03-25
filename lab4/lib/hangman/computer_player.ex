defmodule Hangman.ComputerPlayer do
  use Bitwise

  alias Hangman.{Dictionary, Game}

  def play do
    Dictionary.start_link
    game = Game.new_game
    status = Game.get_status(game)
    
    solver = %{
      candidate_words: load_words_of_length(length(status.letters)),
      letters_left:    (?a..?z) |>Enum.into([]),
    }

    make_a_move(game, solver)
  end

  defp make_a_move(game, solver) do
    { solver, guess } = get_guess(game, solver)
    { game, status } = Game.make_move(game, guess)
    analyze_move(status, game, solver)
  end

  defp analyze_move(%{ game_state: :won, letters: letters}, _, _) do
    IO.puts "I won! The word was: #{letters |> Enum.join}"
  end

  defp analyze_move(%{ game_state: :lost, letters: letters }, _, _) do
    IO.puts "I lost. The word was: #{letters |> Enum.join}"
  end
  
  defp analyze_move(%{
        guess_state: :good_guess,
        last_guess: guess,
        letters: letters}, game, solver) do
    IO.puts "#{inspect guess} was good"
    IO.puts(letters |> Enum.join)
    IO.puts ""
    solver = remove_impossible(solver, letters, guess)
    make_a_move(game, solver)
  end

  defp analyze_move(%{
        guess_state: :bad_guess,
        last_guess: guess,
        letters: letters}, game, solver) do
    IO.puts "#{inspect guess} was bad"
    IO.puts(letters |> Enum.join)
    IO.puts ""

    new_words =
      solver.candidate_words
      |> remove_words_with_letter(guess)
      |> remove_words_not_matching_pattern(letters)

    solver = %{ solver | candidate_words: new_words }
    make_a_move(game, solver)
  end



  defp get_guess(game, solver) do
    freqs = get_frequencies_of_letters(solver.candidate_words,
                                       solver.letters_left)

    {freqs, _} =
      Enum.reduce(freqs,
                  {[], 0},
                  fn {ch, freq}, {result, cf} ->
                    cf = cf + freq
                    { [ { ch, cf} | result ], cf }
                  end)

    { ch, _ } = hd(freqs)
    letters_left = solver.letters_left |> List.delete(ch)

    solver = %{ solver | letters_left: letters_left }

    ch = << ch :: utf8 >>

    if guess_is_possible(solver, game[:word], ch) do
      IO.inspect "#{ch} is possible"
      { solver, ch }
    else
      IO.inspect "#{ch} is NOT possible"
      get_guess(game, solver)
    end
  end

  defp load_words_of_length(len) do
    Hangman.Dictionary.words_of_length(len)
    |> Enum.map(&add_word_signature/1)
  end

  defp add_word_signature(word) do
    with word = String.trim(word), do: { word, word_signature(word)}
  end

  defp word_signature(word) do
    word
    |> String.to_charlist
    |> Enum.map(&(&1 - ?a))
    |> Enum.reduce(0, &(bor(1 <<< &1, &2)))
  end

  defp remove_words_with_letter(candidates, exclude_letter) do
    with char_bit = word_signature(exclude_letter) do
      candidates
      |> Enum.filter(fn { _, signature } -> (signature &&& char_bit) == 0 end)
    end
  end

  defp remove_words_not_matching_pattern(candidates, word_pattern) do
    with re = regexp_from_pattern(word_pattern),
    do: candidates |> Enum.filter(fn { word, _ } -> word =~ re end)
  end

  defp regexp_from_pattern(word_pattern) do
    re_for_word_char = fn
      "_" ->  "."
      ch  ->  ch
    end

    word_pattern
    |> Enum.map(re_for_word_char)
    |> Enum.join
    |> Regex.compile!
  end


  

  # We need to know whether there is any place that a guess could
  # fit. A new guess can only go where there's an underscore
  # in the game state, so we check all the candidate words to
  # see if our guess letter appears in any of them at any
  # open spot.

  defp guess_is_possible(solver, word, guess_ch) do
    Enum.map(word, fn {_ch, known } -> !known end)
    |> check_possibilities(solver.candidate_words, guess_ch)
  end

  defp check_possibilities(_, [], _), do: false
  defp check_possibilities(to_check, [{candidate,_} | rest], guess_ch) do
    candidate
    |> String.codepoints
    |> Enum.zip(to_check)
    |> Enum.filter(fn {_, check} -> check end)
    |> Enum.any?(fn {ch, _} -> ch == guess_ch end)
    || check_possibilities(to_check, rest, guess_ch)
  end

  defp remove_impossible(solver, word, guess_ch) do
    Enum.map(word, fn ch -> ch == guess_ch end)
    |> remove_words_that_conflict_with_current_pattern(solver, guess_ch)
  end

  defp remove_words_that_conflict_with_current_pattern(to_check, solver, guess_ch) do
    with candidates = solver.candidate_words
                      |> Enum.filter(&(word_is_possible(&1, guess_ch, to_check))),
    do: %{ solver | candidate_words: candidates }
  end

  defp word_is_possible({word, _}, guess_ch, to_check) do
    word
    |> String.codepoints
    |> Enum.zip(to_check)
    |> Enum.filter(fn {_, check} -> check end)
    |> Enum.all?(fn {ch, _} -> ch == guess_ch end)
  end


  defp get_frequencies_of_letters(candidates, letters_to_count) do
    letters = Enum.map(letters_to_count, &{ &1, 1 <<< (&1-?a)})
    Enum.reduce(candidates, %{}, &(count_for_one_word(&1, letters, &2)))
    |> Enum.sort(fn {_, a}, {_, b} -> a < b end)
  end

  defp count_for_one_word({_word, signature}, letter_signatures, result) do
    Enum.reduce(letter_signatures, result, fn {letter, letter_signature}, result ->
      if (signature &&& letter_signature) != 0 do
        Map.update(result, letter, 1, &(&1 + 1))
      else
        result
      end
    end)
  end
end
