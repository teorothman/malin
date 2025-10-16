defmodule MalinWeb.ContentLive.Library do
  use MalinWeb, :live_view

  alias Malin.Content

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(page_title: "Content Library", filter_type: nil)

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    user = socket.assigns.current_user
    filter_type = params["type"]

    content_items =
      Content.list_content_items!(actor: user, page: [limit: 100]).results
      |> maybe_filter_by_type(filter_type)

    socket =
      assign(socket,
        content_items: content_items,
        filter_type: filter_type
      )

    {:noreply, socket}
  end

  def handle_event("filter", %{"type" => type}, socket) do
    path =
      if type == "all" do
        ~p"/content"
      else
        ~p"/content?type=#{type}"
      end

    {:noreply, push_patch(socket, to: path)}
  end

  defp maybe_filter_by_type(items, nil), do: items
  defp maybe_filter_by_type(items, "all"), do: items

  defp maybe_filter_by_type(items, type) do
    type_atom = String.to_existing_atom(type)
    Enum.filter(items, fn item -> item.content_type == type_atom end)
  rescue
    ArgumentError -> items
  end

  defp format_content_type(:pdf), do: "PDF"
  defp format_content_type(:video), do: "Video"
  defp format_content_type(:text_article), do: "Article"
  defp format_content_type(:guide), do: "Guide"
  defp format_content_type(:external_link), do: "Link"
  defp format_content_type(_), do: "Unknown"

  defp content_type_icon(:pdf), do: "hero-document-text"
  defp content_type_icon(:video), do: "hero-play-circle"
  defp content_type_icon(:text_article), do: "hero-document"
  defp content_type_icon(:guide), do: "hero-book-open"
  defp content_type_icon(:external_link), do: "hero-arrow-top-right-on-square"
  defp content_type_icon(_), do: "hero-document"
end
