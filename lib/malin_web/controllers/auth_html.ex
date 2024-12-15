defmodule MalinWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use MalinWeb, :html

  embed_templates "auth_html/*"
end
