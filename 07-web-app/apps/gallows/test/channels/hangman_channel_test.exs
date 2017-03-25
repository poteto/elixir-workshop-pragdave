defmodule Gallows.HangmanChannelTest do
  use Gallows.ChannelCase

  alias Gallows.HangmanChannel

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(HangmanChannel, "hangman:game")

    {:ok, socket: socket}
  end
end
