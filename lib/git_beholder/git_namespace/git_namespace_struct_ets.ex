defmodule GitBeholder.GitNamespace.GitNamespaceStructEts do
  @moduledoc """
  Namespace struct using ETS for storage.
  """

  defstruct [:name, :description, :created_at, :updated_at]

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t() | nil,
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @table :git_namespaces

  # Initialize ETS table
  def init_ets do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
  rescue
    # ETS table already exists
    ArgumentError -> :ok
  end

  # Create
  def create(attrs) when is_map(attrs) do
    name = attrs.name
    case :ets.lookup(@table, name) do
      [{^name, _struct}] ->
        {:error, "Namespace already exists"}
      [] ->
        now = DateTime.utc_now()
        struct = %__MODULE__{
          name: name,
          description: Map.get(attrs, :description),
          created_at: now,
          updated_at: now
        }
        :ets.insert(@table, {struct.name, struct})
        {:ok, struct}
    end
  end

  # Read (get by name)
  def get(name) when is_binary(name) do
    case :ets.lookup(@table, name) do
      [{^name, struct}] -> {:ok, struct}
      _ -> {:error, "Not found"}
    end
  end

  # Read all
  def all do
    :ets.tab2list(@table)
    |> Enum.map(fn {_name, struct} -> struct end)
  end

  # Update
  def update(name, attrs) when is_binary(name) and is_map(attrs) do
    case get(name) do
      {:ok, struct} ->
        updated = %__MODULE__{
          struct
          | description: Map.get(attrs, :description, struct.description),
            updated_at: DateTime.utc_now()
        }

        :ets.insert(@table, {name, updated})
        {:ok, updated}

      error ->
        error
    end
  end

  # Delete
  def delete(name) when is_binary(name) do
    :ets.delete(@table, name)
    :ok
  end
end
