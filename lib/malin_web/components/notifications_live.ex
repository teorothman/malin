defmodule MalinWeb.NotificationsComponent do
  use MalinWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, assign(socket, show_dropdown: false)}
  end

  @impl true
  def update(%{current_user: current_user} = assigns, socket) do
    # Load notifications when component updates
    notifications =
      if current_user do
        notifications = Malin.Accounts.notifications_for_user!(actor: current_user)

        # Debug: Check what we're getting
        IO.inspect(notifications, label: "Loaded notifications")

        if length(notifications) > 0 do
          IO.inspect(hd(notifications).post, label: "First notification post")
        end

        notifications
      else
        []
      end

    # Subscribe to real-time notifications if we have a user
    if connected?(socket) && current_user do
      "notifications:#{current_user.id}"
      |> MalinWeb.Endpoint.subscribe()
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:notifications, notifications)}
  end

  @impl true
  def handle_event("toggle-dropdown", _params, socket) do
    {:noreply, assign(socket, show_dropdown: !socket.assigns.show_dropdown)}
  end

  @impl true
  def handle_event("dismiss-notification", %{"id" => id}, socket) do
    current_user = socket.assigns.current_user
    notification = Enum.find(socket.assigns.notifications, &(&1.id == id))

    if notification && current_user do
      Malin.Accounts.dismiss_notification(notification, actor: current_user)

      # Remove from local state for immediate UI update
      notifications = Enum.reject(socket.assigns.notifications, &(&1.id == id))
      {:noreply, assign(socket, notifications: notifications)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("close-dropdown", _params, socket) do
    {:noreply, assign(socket, show_dropdown: false)}
  end

  @impl true
  def handle_event("dismiss-all", _params, socket) do
    current_user = socket.assigns.current_user

    if current_user do
      # Dismiss all notifications
      Enum.each(socket.assigns.notifications, fn notification ->
        Malin.Accounts.dismiss_notification(notification, actor: current_user)
      end)

      {:noreply, assign(socket, notifications: [])}
    else
      {:noreply, socket}
    end
  end

  # Handle real-time notifications from PubSub
  @impl true
  def handle_info(%{topic: "notifications:" <> _}, socket) do
    current_user = socket.assigns.current_user

    if current_user do
      notifications = Malin.Accounts.notifications_for_user!(actor: current_user)
      {:noreply, assign(socket, notifications: notifications)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="relative" id="notifications-dropdown">
      <!-- Notification Bell Button -->
      <button
        type="button"
        phx-click="toggle-dropdown"
        phx-target={@myself}
        class="relative inline-flex items-center p-2 text-sm font-medium text-gray-500 hover:text-gray-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
        aria-expanded={@show_dropdown}
      >
        <span class="sr-only">View notifications</span>
        <!-- Bell Icon (Heroicons) -->
        <.icon name="hero-bell" class="w-6 h-6 text-accent" />
        
    <!-- Notification Badge -->
        <span
          :if={length(@notifications) > 0}
          class="absolute -top-0.5 -right-0.5 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-600 rounded-full"
        >
          {length(@notifications)}
        </span>
      </button>
      
    <!-- Dropdown Menu -->
      <div
        :if={@show_dropdown}
        class="absolute right-0 z-50 mt-2 w-80 bg-white rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
        phx-click-away="close-dropdown"
        phx-target={@myself}
      >
        
    <!-- Dropdown Header -->
        <div class="px-4 py-3 border-b border-gray-200">
          <h3 class="text-sm font-medium text-gray-900">
            Notifications
            <span :if={length(@notifications) > 0} class="ml-1 text-xs text-gray-500">
              ({length(@notifications)})
            </span>
          </h3>
        </div>
        
    <!-- Notifications List -->
        <div class="max-h-96 overflow-y-auto">
          <div :if={length(@notifications) == 0} class="px-4 py-6 text-center">
            <svg
              class="w-12 h-12 mx-auto text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
              />
            </svg>
            <p class="mt-2 text-sm text-gray-500">No new notifications</p>
          </div>

          <div :for={notification <- @notifications} class="group">
            <div class="relative px-4 py-3 hover:bg-gray-50 border-b border-gray-100 last:border-b-0">
              <!-- Notification Content -->
              <div class="flex items-start space-x-3">
                <!-- Post Icon -->
                <div class="flex-shrink-0">
                  <div class="w-8 h-8 bg-accent rounded-full flex items-center justify-center">
                    <svg
                      class="w-4 h-4 text-white"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6v4H7V8z"
                      />
                    </svg>
                  </div>
                </div>
                
    <!-- Notification Text -->
                <div class="flex-1 min-w-0">
                  <p class="text-sm text-gray-900">
                    <%= if notification.post do %>
                      New post: <span class="font-medium">{notification.post.title}</span>
                    <% else %>
                      <span class="text-gray-500">Post no longer available</span>
                    <% end %>
                  </p>
                  <p class="text-xs text-gray-500 mt-1">
                    {time_ago(notification.inserted_at)}
                  </p>
                </div>
                
    <!-- Dismiss Button -->
                <div class="flex-shrink-0">
                  <button
                    type="button"
                    phx-click="dismiss-notification"
                    phx-value-id={notification.id}
                    phx-target={@myself}
                    class="inline-flex items-center p-1 text-gray-400 hover:text-gray-600 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 rounded"
                    title="Dismiss notification"
                  >
                    <span class="sr-only">Dismiss</span>
                    <!-- X Icon (Heroicons) -->
                    <.icon name="hero-x-mark" />
                  </button>
                </div>
              </div>
              
    <!-- Optional: Link to post -->
              <%= if notification.post do %>
                <.link
                  navigate={~p"/posts/#{notification.post.id}"}
                  class="absolute inset-0"
                  phx-click="dismiss-notification"
                  phx-value-id={notification.id}
                  phx-target={@myself}
                >
                  <span class="sr-only">View post</span>
                </.link>
              <% end %>
            </div>
          </div>
        </div>
        
    <!-- Dropdown Footer (optional) -->
        <div :if={length(@notifications) > 0} class="px-4 py-3 border-t border-gray-200 bg-gray-50">
          <button
            type="button"
            class="text-xs text-selected hover:text-selected2 font-medium"
            phx-click="dismiss-all"
            phx-target={@myself}
          >
            Mark all as read
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp time_ago(datetime) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, datetime, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86400 -> "#{div(diff, 3600)}h ago"
      true -> "#{div(diff, 86400)}d ago"
    end
  end
end
