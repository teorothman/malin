defmodule MalinWeb.AnalyticsPlug do
  import Plug.Conn
  require Logger

  def init(default), do: default

  def call(conn, _default) do
    # Track the page view asynchronously to avoid slowing down requests
    Task.start(fn ->
      track_page_view(conn)
    end)

    conn
  end

  defp track_page_view(conn) do
    try do
      path = conn.request_path

      path_with_query =
        case conn.query_string do
          "" -> path
          query -> "#{path}?#{query}"
        end

      case Malin.Analytics.Analytics.track_page_view(conn, path_with_query) do
        {:ok, _} ->
          Logger.debug("Analytics: Tracked page view for #{path_with_query}")

        {:error, reason} ->
          Logger.warning(
            "Analytics: Failed to track page view for #{path_with_query}: #{inspect(reason)}"
          )
      end
    rescue
      error ->
        Logger.error("Analytics: Exception tracking page view: #{inspect(error)}")
    end
  end
end
