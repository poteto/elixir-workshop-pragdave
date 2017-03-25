defmodule Hangman.GameSupervisor do
  @super :game_supervisor

  def start_link do
    import Supervisor.Spec

    children = [
      worker(Hangman.GameServer, [], restart: :transient)
    ]

    Supervisor.start_link(children, name: @super, strategy: :simple_one_for_one)
  end
  

  def new_game(),                          do: new_game([])
  def new_game(word) when is_binary(word), do: new_game([word])

  def new_game(params) when is_list(params) do
    { :ok, pid } = IO.inspect(Supervisor.start_child(@super, params), pretty: true)
    pid
  end

end
