defmodule OpenaiEx.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias OpenaiEx.Error

  @status ~w(complete cancelled length)a
  @role ~w(system user assistant function)a

  @primary_key false
  embedded_schema do
    field(:content, :string)
    field(:role, Ecto.Enum, values: @role, default: :user)
    field(:metadata, :map, default: %{})
  end

  @create_fields ~w(role content metadata)a
  @required_fields ~w(role)a

  def new(attrs \\ %{}) do
    %Message{}
    |> cast(attrs, @create_fields)
    # |> parse_arguments()
    |> common_validations()
    |> apply_action(:insert)
  end

  def new!(attrs \\ %{}) do
    case new(attrs) do
      {:ok, message} ->
        message

      {:error, changeset} ->
        raise Error, changeset
    end
  end

  defp common_validations(changeset) do
    changeset
    |> validate_required(@required_fields)
    |> validate_content()
  end

  defp validate_content(changeset) do
    case fetch_field!(changeset, :role) do
      role when role in [:system, :user] ->
        validate_required(changeset, [:content])

      _other ->
        changeset
    end
  end

  def new_user(content, metadata \\ %{}) do
    new(%{role: :user, content: content, metadata: metadata})
  end

  def new_user!(content, metadata \\ %{}) do
    new!(%{role: :user, content: content, metadata: metadata})
  end
end
