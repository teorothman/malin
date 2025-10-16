defmodule MalinWeb.ContentLive.Index do
  use MalinWeb, :live_view

  alias Malin.Content

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(page_title: "Content Management")

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    user = socket.assigns.current_user
    content_items = Content.list_content_items_admin!(actor: user, page: [limit: 100]).results

    socket = assign(socket, content_items: content_items)

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    content_item = Content.get_content_item!(id, actor: user, load: [:author])

    case Content.delete_content_item(content_item, actor: user) do
      {:ok, _} ->
        content_items = Content.list_content_items_admin!(actor: user, page: [limit: 100]).results

        {:noreply,
         socket
         |> put_flash(:info, "Content item deleted successfully")
         |> assign(content_items: content_items)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete content item")}
    end
  end

  defp format_content_type(:pdf), do: "PDF"
  defp format_content_type(:video), do: "Video"
  defp format_content_type(:text_article), do: "Text Article"
  defp format_content_type(:guide), do: "Guide"
  defp format_content_type(:external_link), do: "External Link"
  defp format_content_type(_), do: "Unknown"

  defp state_badge_class(:draft), do: "bg-gray-100 text-gray-800"
  defp state_badge_class(:published), do: "bg-green-100 text-green-800"
  defp state_badge_class(:archived), do: "bg-yellow-100 text-yellow-800"
  defp state_badge_class(_), do: "bg-gray-100 text-gray-800"
end
