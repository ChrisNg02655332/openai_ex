defmodule OpenaiEx.ChatMessage do
  @map_fields [
    :content,
    :role,
    :file_ids,
    :name,
    :meta,
    :tool_call_id
  ]

  # defp new(args = [_ | _]), do: args |> Enum.into(%{}) |> new()

  defp new(params = %{}) do
    params
    |> Map.take(@map_fields)
    |> Enum.filter(fn {_, v} -> !is_nil(v) end)
    |> Enum.into(%{})
  end

  @doc """
  Create a `ChatMessage` map with role `user`.

  Example usage:

      iex> _message = OpenaiEx.ChatMessage.user("Hello, world!")
      %{content: "Hello, world!", role: "user"}
  """
  def user(args), do: new(args |> Map.put(:role, "user"))
end
