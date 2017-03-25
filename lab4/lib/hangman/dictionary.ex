defmodule Hangman.Dictionary do

  @word_list_file_name Path.expand("../../assets/words.8800", __DIR__)

  @me :dictionary

  def start_link(word_list_file \\ @word_list_file_name) do
    Agent.start_link(__MODULE__, :word_list, [word_list_file], name: @me)
    # this is where you'll start the agent, storing the list
    # of words in the given file as its state
  end

  # change this function to use the Agent state as the word list
  def random_word do
    Agent.get(@me, fn word_list ->
      word_list
      |> Enum.random
      |> String.trim
    end)
  end

  # do the same here
  def words_of_length(len) do
    Agent.get(@me, fn word_list ->
      word_list
      |> Enum.filter(&(String.length(&1) == len))
    end)
  end

  # this won't change. (Hint: it might be a good function to
  # call from inside the agent initialization)
  def word_list(file_name \\ @word_list_file_name) do
    file_name
    |> File.stream!
    |> Stream.map(&String.trim/1)
    |> Enum.to_list
  end

end
