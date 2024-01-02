defmodule OpenaiEx.Beta.Thread.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias OpenaiEx.Error
  alias OpenaiEx.Beta.Schema.MessageContent
  import OpenaiEx.Api

  require Logger

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:object, :string)
    field(:created_at, :integer)
    field(:thread_id, :string)
    field(:role, Ecto.Enum, values: [:assistant, :user])

    embeds_many(:content, MessageContent)

    field(:file_ids, {:array, :string})
    field(:assistant_id, :string)
    field(:run_id, :string)

    field(:meta, :map, default: %{})
  end

  @create_fields ~w(id object created_at thread_id role)a

  def new(%{} = attrs \\ %{}) do
    %Message{}
    |> cast(attrs, @create_fields)
    |> cast_embed(:content)
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

  def create(thread_id, chat_msg) do
    url = "/threads/#{thread_id}/messages"

    prepare(url)
    |> put_header("OpenAI-Beta", "assistants=v1")
    |> Req.post(body: Jason.encode!(chat_msg))
    |> handle_response()
  end

  defp handle_response(res, method \\ nil) do
    res
    |> case do
      {:ok, %Req.Response{body: data}} ->
        case method do
          :delete -> %{id: data["id"], object: data["object"], deleted: data["deleted"]}
          _ -> Message.new!(data)
        end

      {:error, %Mint.TransportError{reason: :timeout}} ->
        {:error, "Request timed out"}

      other ->
        Logger.error("Unexpected and unhandled API response! #{inspect(other)}")
        other
    end
  end
end
