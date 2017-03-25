defmodule DictionaryTest do
  use ExUnit.Case

  alias Hangman.Dictionary
  
  test "reads the correct word list" do
    Dictionary.start_link("test/lists/one_word.txt")
    assert Dictionary.random_word == "koala"
  end

  test "finds words of a particular length" do
    Dictionary.start_link("test/lists/three_and_four_letters.txt")
    words = Dictionary.words_of_length(3)
    assert Enum.sort(words) == [ "cat", "dog" ]
    words = Dictionary.words_of_length(4)
    assert Enum.sort(words) == [ "colt", "deer" ]
  end
end
