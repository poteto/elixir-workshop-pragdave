defmodule Hangman.Dictionary do

  use GenServer

  @word_list_file_name Path.expand("../../assets/words.8800", __DIR__)

  @name :dictionary

  def start_link(word_list_file_name \\ @word_list_file_name) do
    GenServer.start_link(__MODULE__, word_list_file_name, name: @name)
  end

  def random_word do
    GenServer.call(@name, { :random_word })
  end

  def words_of_length(len) do
    GenServer.call(@name, { :words_of_length, len })
  end


  def crash(reason) do
    GenServer.cast(@name, {:crash, reason})
  end

  ###########################
  # End of public interface #
  ###########################

  def init(word_list_file_name) do
    list = word_list_file_name
           |> File.stream!
           |> Stream.map(&String.trim/1)
           |> Enum.to_list
    { :ok, list }
  end

  def handle_call({ :random_word }, _from, word_list) do
    result = word_list |> Enum.random |> String.trim
    { :reply, result, word_list }
  end

  def handle_call({ :words_of_length, len }, _from, word_list)  do
    result = word_list |> Enum.filter(&(String.length(&1) == len))
    { :reply, result, word_list }
  end

  def handle_cast({:crash, reason}, word_list) do
    { :stop, reason, word_list }
  end
end
