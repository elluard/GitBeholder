defmodule GitBeholderWeb.GitNamespaceController do
  use GitBeholderWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "ok", namespaces: ["namespace1", "namespace2", "namespace3"]})
  end

  def create(conn, %{"namespace" => namespace}) do
    json(conn, %{status: "ok", namespace: namespace})
  end

  def update(conn, %{"namespace" => namespace}) do
    json(conn, %{status: "ok", namespace: namespace})
  end

  def delete(conn, %{"namespace" => namespace}) do
    json(conn, %{status: "ok", namespace: namespace})
  end
end
