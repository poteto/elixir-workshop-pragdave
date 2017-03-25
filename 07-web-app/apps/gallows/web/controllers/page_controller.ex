defmodule Gallows.PageController do
  use Gallows.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
