defmodule GitBeholder.GitNamespace.GitNamespaceBehaviour do
  @moduledoc """
  Behaviour for Git Namespace operations.
  """
  alias GitBeholder.GitNamespace.GitNamesaceStruct

  @callback get_namespaces() :: [String.t()]
  @callback create_namespace(String.t()) :: {:ok, GitNamesaceStruct.t()} | {:error, String.t()}
  @callback update_namespace(String.t()) :: {:ok, GitNamesaceStruct.t()} | {:error, String.t()}
  @callback delete_namespace(String.t()) :: {:ok} | {:error, String.t()}
  @callback get_namespace(String.t()) :: {:ok, GitNamesaceStruct.t()} | {:error, String.t()}
end
