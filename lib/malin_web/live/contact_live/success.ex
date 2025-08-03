defmodule MalinWeb.ContactLive.Success do
  use MalinWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center flex-col gap-8">
      <h1 class="text-4xl font-bold">TACK för din meddelande!</h1>
      <div class="flex items-center justify-center flex-col gap-2">
        <p>Jag ser så fram emot att få prata med dig!</p>
        <p>
          Medan jag kikar på ditt meddelande, så rekommenderar jag att du tar en titt på mina freebies!
        </p>
        <p>Följ länken i mejlet för att se gamla nyhetsbrev eller skicka fler meddelanden!</p>
      </div>
    </div>
    """
  end
end
