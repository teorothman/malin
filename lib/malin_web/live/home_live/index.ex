defmodule MalinWeb.HomeLive.Index do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    socket =
      socket
      |> assign(page_title: "Home")

    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
