defmodule MalinWeb.ContentLive.Show do
  use MalinWeb, :live_view

  alias Malin.Content

  def mount(_params, _sessions, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    user = socket.assigns.current_user
    content_item = Content.get_content_item!(id, actor: user, load: [:author])

    socket =
      assign(socket,
        content_item: content_item,
        page_title: content_item.title
      )

    {:noreply, socket}
  end

  defp format_content_type(:pdf), do: "PDF Document"
  defp format_content_type(:video), do: "Video"
  defp format_content_type(:text_article), do: "Article"
  defp format_content_type(:guide), do: "Guide"
  defp format_content_type(:external_link), do: "External Link"
  defp format_content_type(_), do: "Content"

  defp extract_youtube_id(url) when is_binary(url) do
    # Match various YouTube URL formats
    # https://www.youtube.com/watch?v=VIDEO_ID
    # https://youtube.com/watch?v=VIDEO_ID
    # https://youtu.be/VIDEO_ID
    # https://www.youtube.com/embed/VIDEO_ID
    cond do
      # Standard youtube.com/watch?v= format
      Regex.match?(~r/youtube\.com\/watch\?v=([^&]+)/, url) ->
        [_, video_id] = Regex.run(~r/youtube\.com\/watch\?v=([^&]+)/, url)
        video_id

      # Short youtu.be/ format
      Regex.match?(~r/youtu\.be\/([^?]+)/, url) ->
        [_, video_id] = Regex.run(~r/youtu\.be\/([^?]+)/, url)
        video_id

      # Embed format
      Regex.match?(~r/youtube\.com\/embed\/([^?]+)/, url) ->
        [_, video_id] = Regex.run(~r/youtube\.com\/embed\/([^?]+)/, url)
        video_id

      true ->
        nil
    end
  end

  defp extract_youtube_id(_), do: nil

  defp extract_vimeo_id(_url), do: nil

  defp simple_markdown_to_html(text) do
    text
    |> String.replace(~r/\n\n/, "</p><p>")
    |> String.replace(~r/\*\*(.+?)\*\*/, "<strong>\\1</strong>")
    |> String.replace(~r/\*(.+?)\*/, "<em>\\1</em>")
    |> String.replace(~r/\n/, "<br>")
    |> then(&("<p>" <> &1 <> "</p>"))
  end
end
