defmodule Chat.Message do
  use Chat.Web, :model

  schema "messages" do
    field :body, :string
    belongs_to :room, Chat.Room

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body])
    |> validate_required([:body])
  end

  # @derive [Poison.Encoder]
  # defstruct [:body]
end
