defmodule CelebrateWeb.PageController do
  use CelebrateWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def all(conn, _parms) do
    render conn, "all.html"
  end
end
