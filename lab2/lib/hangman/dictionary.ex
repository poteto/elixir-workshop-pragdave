defmodule Hangman.Dictionary do

  @word_list_file_name Path.expand("../../assets/words.8800", __DIR__)

  @word_list @word_list_file_name
             |> File.stream!
             |> Stream.map(&String.trim/1)
             |> Enum.to_list

  def random_word do
    @word_list
    |> Enum.random
    |> String.trim
  end

  def words_of_length(len) do
    @word_list
    |> Enum.filter(&(String.length(&1) == len))
  end

end
