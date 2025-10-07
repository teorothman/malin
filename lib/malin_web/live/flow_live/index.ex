defmodule MalinWeb.FlowLive.Index do
  use MalinWeb, :live_view

  def mount(_params, _sessions, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    socket =
      assign(socket, page_title: "Flowmakers")

    {:noreply, socket}
  end
end
