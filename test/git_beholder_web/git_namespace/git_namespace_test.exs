defmodule GitBeholder.GitNamespaceTest do
  use ExUnit.Case, async: true

  alias GitBeholder.GitNamespace.GitNamespaceStructEts

  setup do
    # Ensure the ETS table is clean before each test
    try do
      :ets.delete(:git_namespaces)
    rescue
      _ -> :ok
    end
    GitNamespaceStructEts.init_ets()
    :ok
  end

  test "create and get namespace" do
    {:ok, ns} = GitNamespaceStructEts.create(%{name: "dev", description: "development"})
    assert ns.name == "dev"
    assert ns.description == "development"

    {:ok, found} = GitNamespaceStructEts.get("dev")
    assert found.name == "dev"
    assert found.description == "development"
  end

  test "error on duplicate namespace" do
    {:ok, _} = GitNamespaceStructEts.create(%{name: "dev"})
    assert {:error, "Namespace already exists"} = GitNamespaceStructEts.create(%{name: "dev"})
  end

  test "all returns all namespaces" do
    GitNamespaceStructEts.create(%{name: "dev"})
    GitNamespaceStructEts.create(%{name: "prod"})
    names = GitNamespaceStructEts.all() |> Enum.map(& &1.name)
    assert Enum.sort(names) == ["dev", "prod"]
  end

  test "update namespace" do
    GitNamespaceStructEts.create(%{name: "dev", description: "old"})
    {:ok, updated} = GitNamespaceStructEts.update("dev", %{description: "new"})
    assert updated.description == "new"
    {:ok, found} = GitNamespaceStructEts.get("dev")
    assert found.description == "new"
  end

  test "delete namespace" do
    GitNamespaceStructEts.create(%{name: "dev"})
    :ok = GitNamespaceStructEts.delete("dev")
    assert {:error, _} = GitNamespaceStructEts.get("dev")
  end

  test "get returns error for missing namespace" do
    assert {:error, _} = GitNamespaceStructEts.get("not_exist")
  end
end
