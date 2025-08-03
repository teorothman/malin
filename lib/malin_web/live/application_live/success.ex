defmodule MalinWeb.ApplicationLive.Success do
  use MalinWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center flex-col">
      <h1 class="text-4xl font-bold">TACK för din ansökan!</h1>
      <p>Jag ser så fram emot att få prata med dig!</p>
      <p>Medan jag kikar på din ansökan, så rekommenderar jag att du tar en titt på mina freebies!</p>
      <p>Om du vill läsa gamla nyhetsbrev eller ändra din ansökan så kan du klicka på logga in.</p>
    </div>
    """
  end
end
