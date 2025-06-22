defmodule GitBeholder.GitRepository do
  def root_path do
    try do
      loader = Application.get_env(:git_beholder, :property_loader, GitBeholder.PropertyLoader)
      root_dir = loader.get_root_directory()

      repos =
        root_dir
        |> File.ls!()
        |> Enum.map(&Path.join(root_dir, &1))
        |> Enum.filter(&File.dir?/1)
        |> Enum.filter(fn dir -> File.dir?(Path.join(dir, ".git")) end)
        |> Enum.map(&Path.basename/1)

      {:ok, repos, root_dir}
    rescue
      e in File.Error ->
        {:error, "File system error: #{Exception.message(e)}"}
      e ->
        {:error, "Unknown error: #{Exception.message(e)}"}
    end
  end

  def create_repository(repo_name) when is_binary(repo_name) and repo_name != "" do
    loader = Application.get_env(:git_beholder, :property_loader, GitBeholder.PropertyLoader)
    root_dir = loader.get_root_directory()
    repo_path = Path.join(root_dir, repo_name)

    cond do
      File.exists?(repo_path) ->
        {:error, "Repository already exists: #{repo_path}"}

      true ->
        case File.mkdir_p(repo_path) do
          :ok ->
            {output, exit_code} = System.cmd("git", ["init"], cd: repo_path, stderr_to_stdout: true)
            if exit_code == 0 do
              {:ok, repo_path, output}
            else
              {:error, "git init failed: #{output}"}
            end

          {:error, reason} ->
            {:error, "Failed to create directory: #{inspect(reason)}"}
        end
    end
  end

  def delete_repository(repo_name) when is_binary(repo_name) and repo_name != "" do
    loader = Application.get_env(:git_beholder, :property_loader, GitBeholder.PropertyLoader)
    root_dir = loader.get_root_directory()
    repo_path = Path.join(root_dir, repo_name)

    cond do
      !File.exists?(repo_path) ->
        {:error, "Repository does not exist: #{repo_path}"}

      true ->
        case File.rm_rf(repo_path) do
          {:ok, _} -> {:ok, "Repository deleted successfully"}
          {:error, reason, _} -> {:error, "Failed to delete repository: #{inspect(reason)}"}
        end
    end
  end
end
