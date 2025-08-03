defmodule Malin.Analytics.Analytics do
  require Ash.Query
  alias Malin.Analytics.Pageview

  def track_page_view(conn, path) do
    user_agent = get_user_agent(conn)

    Pageview
    |> Ash.Changeset.for_create(:track, %{
      path: path,
      referrer: get_referrer(conn),
      user_agent: user_agent,
      country: get_country_from_ip(conn),
      browser: parse_browser(user_agent),
      os: parse_os(user_agent)
    })
    |> Ash.create()
  end

  def get_stats(date_range \\ 30) do
    Pageview
    |> Ash.Query.filter(viewed_at >= ago(^date_range, :day))
    |> Ash.read()
    |> case do
      {:ok, page_views} -> {:ok, %{total_views: length(page_views)}}
      error -> error
    end
  end

  def get_page_stats(date_range \\ 30) do
    Pageview
    |> Ash.Query.filter(viewed_at >= ago(^date_range, :day))
    |> Ash.read()
    |> case do
      {:ok, page_views} ->
        stats =
          page_views
          |> Enum.group_by(& &1.path)
          |> Enum.map(fn {path, views} ->
            %{path: path, count: length(views)}
          end)
          |> Enum.sort_by(& &1.count, :desc)

        {:ok, stats}

      error ->
        error
    end
  end

  # Helper functions remain the same...
  defp get_user_agent(conn) do
    case Plug.Conn.get_req_header(conn, "user-agent") do
      [ua | _] -> ua
      [] -> nil
    end
  end

  defp get_referrer(conn) do
    case Plug.Conn.get_req_header(conn, "referer") do
      [ref | _] -> ref
      [] -> nil
    end
  end

  defp get_country_from_ip(conn) do
    case Plug.Conn.get_req_header(conn, "cf-ipcountry") do
      [country | _] -> country
      [] -> "Unknown"
    end
  end

  defp parse_browser(user_agent) when is_binary(user_agent) do
    cond do
      String.contains?(user_agent, "Chrome") -> "Chrome"
      String.contains?(user_agent, "Firefox") -> "Firefox"
      String.contains?(user_agent, "Safari") -> "Safari"
      String.contains?(user_agent, "Edge") -> "Edge"
      true -> "Other"
    end
  end

  defp parse_browser(_), do: "Unknown"

  defp parse_os(user_agent) when is_binary(user_agent) do
    cond do
      String.contains?(user_agent, "Windows") -> "Windows"
      String.contains?(user_agent, "Mac") -> "macOS"
      String.contains?(user_agent, "Linux") -> "Linux"
      String.contains?(user_agent, "Android") -> "Android"
      String.contains?(user_agent, "iOS") -> "iOS"
      true -> "Other"
    end
  end

  defp parse_os(_), do: "Unknown"
end
