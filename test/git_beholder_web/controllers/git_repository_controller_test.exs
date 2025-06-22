defmodule GitBeholder.PropertyLoaderMock do
  @behaviour GitBeholder.PropertyLoaderBehaviour

  def get_root_directory, do: Application.get_env(:git_beholder, :test_root_directory)
end

defmodule GitBeholderWeb.GitRepositoryControllerTest do
  use GitBeholderWeb.ConnCase, async: true

  @test_root Path.expand("./test_repos", __DIR__)

  setup do
    File.rm_rf!(@test_root)
    File.mkdir_p!(@test_root)

    repo1 = Path.join(@test_root, "repo1")
    repo2 = Path.join(@test_root, "repo2")
    non_git = Path.join(@test_root, "not_a_repo")
    File.mkdir_p!(repo1)
    File.mkdir_p!(repo2)
    File.mkdir_p!(non_git)
    File.mkdir_p!(Path.join(repo1, ".git"))
    File.mkdir_p!(Path.join(repo2, ".git"))

    # create folder for testing deleting repositories
    delete_test_repo = Path.join(@test_root, "delete_test_repo")
    File.mkdir_p!(delete_test_repo)
    File.mkdir_p!(Path.join(delete_test_repo, ".git"))

    # Set environment variable to use PropertyLoaderMock in the test environment
    Application.put_env(:git_beholder, :test_root_directory, @test_root)
    Application.put_env(:git_beholder, :property_loader, GitBeholder.PropertyLoaderMock)

    on_exit(fn ->
      File.rm_rf!(@test_root)
      Application.delete_env(:git_beholder, :test_root_directory)
      Application.delete_env(:git_beholder, :property_loader)
    end)

    :ok
  end

  test "GET /repositories lists only git repositories", %{conn: conn} do
    conn = get(conn, "/api/git/repositories")
    %{"status" => "ok", "repositories" => repos} = json_response(conn, 200)
    assert "repo1" in repos
    assert "repo2" in repos
    refute "not_a_repo" in repos
  end

  test "POST /repositories creates a new repository", %{conn: conn} do
    conn = post(conn, "/api/git/repositories", %{"repo_name" => "new_repo"})

    assert json_response(conn, 200) == %{
             "status" => "ok",
             "message" => "Repository created at #{@test_root}/new_repo"
           }

    # Verify the repository was created
    assert File.exists?(Path.join(@test_root, "new_repo/.git"))
  end

  test "POST /repositories fails with existing repository", %{conn: conn} do
    conn = post(conn, "/api/git/repositories", %{"repo_name" => "repo1"})

    assert json_response(conn, 400) == %{
             "status" => "error",
             "message" => "Repository already exists: #{@test_root}/repo1"
           }
  end

  test "DELETE /repositories/:repo_name deletes a repository", %{conn: conn} do
    conn = delete(conn, "/api/git/repositories/delete_test_repo")

    assert json_response(conn, 200) == %{
             "status" => "ok",
             "message" => "Repository deleted successfully"
           }

    # Verify the repository was deleted
    refute File.exists?(Path.join(@test_root, "delete_test_repo/.git"))
  end

  test "DELETE /repositories/:repo_name fails with non-existing repository", %{conn: conn} do
    conn = delete(conn, "/api/git/repositories/non_existing_repo")

    assert json_response(conn, 400) == %{
             "status" => "error",
             "message" => "Repository does not exist: #{@test_root}/non_existing_repo"
           }
  end
end
