defmodule Gallows.PageControllerTest do
  use Gallows.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "<svg"
  end
end
