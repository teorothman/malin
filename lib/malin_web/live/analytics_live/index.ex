defmodule MalinWeb.AnalyticsLive.Index do
  use MalinWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    # Always set default values as lists, not atoms
    socket =
      assign(socket,
        total_views: 0,
        unique_paths: 0,
        top_pages: [],
        daily_views: [],
        browser_stats: [],
        country_stats: [],
        os_stats: [],
        date_range: 30,
        loading: true
      )

    if connected?(socket) do
      # Load analytics data when the LiveView connects
      socket = load_analytics_data(socket)
      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def handle_event("change_date_range", %{"date_range" => date_range}, socket) do
    date_range = String.to_integer(date_range)

    socket =
      socket
      |> assign(:date_range, date_range)
      |> assign(:loading, true)
      |> load_analytics_data()

    {:noreply, socket}
  end

  def handle_event("refresh_data", _params, socket) do
    socket =
      socket
      |> assign(:loading, true)
      |> load_analytics_data()

    {:noreply, socket}
  end

  defp load_analytics_data(socket) do
    date_range = socket.assigns[:date_range] || 30

    try do
      {total_views, page_stats} =
        case {Malin.Analytics.Analytics.get_stats(date_range),
              Malin.Analytics.Analytics.get_page_stats(date_range)} do
          {{:ok, stats}, {:ok, pages}} -> {stats.total_views, pages}
          {{:ok, stats}, {:error, _}} -> {stats.total_views, []}
          {{:error, _}, {:ok, pages}} -> {0, pages}
          {{:error, _}, {:error, _}} -> {0, []}
          _ -> {0, []}
        end

      # Get additional analytics data
      browser_stats = get_browser_stats(date_range)
      country_stats = get_country_stats(date_range)
      os_stats = get_os_stats(date_range)
      daily_views = get_daily_views(date_range)

      assign(socket,
        total_views: total_views,
        unique_paths: length(page_stats),
        top_pages: Enum.take(page_stats, 10),
        daily_views: daily_views,
        browser_stats: browser_stats,
        country_stats: country_stats,
        os_stats: os_stats,
        loading: false
      )
    rescue
      error ->
        Logger.error("Failed to load analytics data: #{inspect(error)}")

        assign(socket,
          total_views: 0,
          unique_paths: 0,
          top_pages: [],
          daily_views: [],
          browser_stats: [],
          country_stats: [],
          os_stats: [],
          loading: false
        )
    end
  end

  defp get_browser_stats(date_range) do
    require Ash.Query

    try do
      case Malin.Analytics.Pageview
           |> Ash.Query.filter(viewed_at >= ago(^date_range, :day))
           |> Ash.read() do
        {:ok, page_views} when is_list(page_views) ->
          page_views
          |> Enum.group_by(& &1.browser)
          |> Enum.map(fn {browser, views} ->
            %{name: browser || "Unknown", count: length(views)}
          end)
          |> Enum.sort_by(& &1.count, :desc)
          |> Enum.take(5)

        {:error, reason} ->
          Logger.warning("Failed to get browser stats: #{inspect(reason)}")
          []

        _ ->
          []
      end
    rescue
      error ->
        Logger.error("Exception in get_browser_stats: #{inspect(error)}")
        []
    end
  end

  defp get_country_stats(date_range) do
    require Ash.Query

    try do
      case Malin.Analytics.Pageview
           |> Ash.Query.filter(viewed_at >= ago(^date_range, :day))
           |> Ash.read() do
        {:ok, page_views} when is_list(page_views) ->
          page_views
          |> Enum.group_by(& &1.country)
          |> Enum.map(fn {country, views} ->
            %{name: country || "Unknown", count: length(views)}
          end)
          |> Enum.sort_by(& &1.count, :desc)
          |> Enum.take(5)

        {:error, reason} ->
          Logger.warning("Failed to get country stats: #{inspect(reason)}")
          []

        _ ->
          []
      end
    rescue
      error ->
        Logger.error("Exception in get_country_stats: #{inspect(error)}")
        []
    end
  end

  defp get_os_stats(date_range) do
    require Ash.Query

    try do
      case Malin.Analytics.Pageview
           |> Ash.Query.filter(viewed_at >= ago(^date_range, :day))
           |> Ash.read() do
        {:ok, page_views} when is_list(page_views) ->
          page_views
          |> Enum.group_by(& &1.os)
          |> Enum.map(fn {os, views} ->
            %{name: os || "Unknown", count: length(views)}
          end)
          |> Enum.sort_by(& &1.count, :desc)
          |> Enum.take(5)

        {:error, reason} ->
          Logger.warning("Failed to get OS stats: #{inspect(reason)}")
          []

        _ ->
          []
      end
    rescue
      error ->
        Logger.error("Exception in get_os_stats: #{inspect(error)}")
        []
    end
  end

  defp get_daily_views(date_range) do
    require Ash.Query

    try do
      case Malin.Analytics.Pageview
           |> Ash.Query.filter(viewed_at >= ago(^date_range, :day))
           |> Ash.read() do
        {:ok, page_views} when is_list(page_views) ->
          # Group by date
          page_views
          |> Enum.group_by(fn view ->
            view.viewed_at
            |> DateTime.to_date()
            |> Date.to_string()
          end)
          |> Enum.map(fn {date, views} ->
            %{date: date, views: length(views)}
          end)
          |> Enum.sort_by(& &1.date)
          # Last 14 days for chart
          |> Enum.take(-14)

        {:error, reason} ->
          Logger.warning("Failed to get daily views: #{inspect(reason)}")
          []

        _ ->
          []
      end
    rescue
      error ->
        Logger.error("Exception in get_daily_views: #{inspect(error)}")
        []
    end
  end

  defp format_number(number) when number >= 1000 do
    "#{Float.round(number / 1000, 1)}k"
  end

  defp format_number(number), do: to_string(number)
end
