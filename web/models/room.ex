defmodule Chat.Room do
  use Chat.Web, :model

  schema "rooms" do
    field :uuid, :string

    has_many :messages, Chat.Message

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:uuid])
    |> validate_required([:uuid])
  end
end
