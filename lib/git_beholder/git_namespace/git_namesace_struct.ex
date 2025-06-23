defmodule GitBeholder.GitNamespace.GitNamesaceStruct do
  defstruct [:name, :description, :created_at, :updated_at]

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t() | nil,
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }
end
