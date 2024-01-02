defmodule OpenaiEx.Beta.Thread do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias OpenaiEx.Error
  import OpenaiEx.Api

  require Logger

  @url "/threads"

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:object, :string)
    field(:created_at, :integer)
    field(:meta, :map, default: %{})
  end

  @create_fields ~w(id object created_at meta)a

  def new(%{} = attrs \\ %{}) do
    %Thread{}
    |> cast(attrs, @create_fields)
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

  def create() do
    prepare(@url)
    |> put_header("OpenAI-Beta", "assistants=v1")
    |> Req.post()
    |> handle_response()
  end

  def retrieve(thread_id) do
    prepare(@url <> "/#{thread_id}")
    |> put_header("OpenAI-Beta", "assistants=v1")
    |> Req.get()
    |> handle_response()
  end

  def delete(thread_id) do
    prepare(@url <> "/#{thread_id}")
    |> put_header("OpenAI-Beta", "assistants=v1")
    |> Req.delete()
    |> handle_response(:delete)
  end

  defp handle_response(res, method \\ nil) do
    res
    |> case do
      {:ok, %Req.Response{body: data}} ->
        case method do
          :delete -> %{id: data["id"], object: data["object"], deleted: data["deleted"]}
          _ -> Thread.new!(data)
        end

      {:error, %Mint.TransportError{reason: :timeout}} ->
        {:error, "Request timed out"}

      other ->
        Logger.error("Unexpected and unhandled API response! #{inspect(other)}")
        other
    end
  end
end
