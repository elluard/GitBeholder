defmodule GitBeholderWeb.GitRepositoryController do
  use GitBeholderWeb, :controller

  alias GitBeholder.GitRepository

  def index(conn, _params) do
    case GitRepository.root_path() do
      {:ok, repos, _root_dir} ->
        json(conn, %{status: "ok", repositories: repos})

      {:error, error_msg} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{status: "error", message: error_msg})
    end
  end

  def create(conn, %{"repo_name" => repo_name}) do
    case GitRepository.create_repository(repo_name) do
      {:ok, repo_path, _output} ->
        json(conn, %{status: "ok", message: "Repository created at #{repo_path}"})

      {:error, error_msg} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", message: error_msg})
    end
  end

  def delete(conn, %{"repo_name" => repo_name}) do
    case GitRepository.delete_repository(repo_name) do
      {:ok, message} ->
        json(conn, %{status: "ok", message: message})

      {:error, error_msg} ->
        conn
        |> put_status(:bad_request)
        |> json(%{status: "error", message: error_msg})
    end
  end
end
