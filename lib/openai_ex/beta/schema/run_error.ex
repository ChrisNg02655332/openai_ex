defmodule OpenaiEx.Beta.Schema.RunError do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:code, Ecto.Enum, values: [:server_error, :rate_limit_exceeded])
    field(:message, :string)
  end

  def changeset(_, attrs) when is_nil(attrs), do: nil

  def changeset(run_error, attrs) do
    run_error
    |> cast(attrs, [:code, :message])
  end
end

defmodule OpenaiEx.Beta.Schema.RunRequiredAction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:type, Ecto.Enum, values: [:submit_tool_outputs])
    field(:submit_tool_outputs, :map)
  end

  def changeset(_, attrs) when is_nil(attrs), do: nil

  def changeset(run_required_action, attrs) do
    run_required_action
    |> cast(attrs, [:type, :submit_tool_outputs])
  end
end
