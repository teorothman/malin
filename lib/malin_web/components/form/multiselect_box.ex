defmodule MalinWeb.Forms.MultiselectBox do
  use MalinWeb, :html

  attr :field, Phoenix.HTML.FormField, required: true

  attr :options, :list,
    required: true,
    doc: "Expects a list of structs with an id field"

  attr :label, :string,
    required: false,
    default: nil,
    doc: "The label for the multiselect box"

  attr :options_label_key, :atom,
    default: :name,
    doc: "The field name to use as the label for the options"

  attr :grid_class_names, :string,
    default: "grid-cols-2 lg:grid-cols-3",
    doc: "The class names for the grid container"

  def multiselect_box(assigns) do
    ~H"""
    <div class="flex flex-col gap-1">
      <%= if @label do %>
        <.label>
          {@label} <span class="text-accent">*</span>
        </.label>
      <% end %>
      <div class={[
        "grid gap-2",
        @grid_class_names
      ]}>
        <%= for option <- @options do %>
          <label class={[
            "cursor-pointer px-3 py-2 rounded-lg text-white text-sm overflow-hidden line-clamp-2",
            is_checked?(@field, option) && "bg-brand",
            !is_checked?(@field, option) && "bg-selected"
          ]}>
            <input
              type="checkbox"
              name={"#{@field.name}[]"}
              value={field_value(option)}
              checked={is_checked?(@field, option)}
              class="hidden"
            />
            {Map.get(option, @options_label_key)}
          </label>
        <% end %>
      </div>
    </div>
    """
  end

  defp field_value(%{id: id}), do: id
  defp field_value({id, _bool}), do: id
  defp field_value(id), do: id

  defp is_checked?(%{value: value}, opt) when is_list(value) do
    value = Enum.map(value, &field_value/1)
    Enum.any?(value, fn v -> v == field_value(opt) end)
  end

  defp is_checked?(%{value: value}, opt) when is_map(value) do
    Map.get(value, field_value(opt), false)
  end

  defp is_checked?(_, _), do: false

  def handle_event(
        "toggle_option",
        %{"category_id" => category_id, "option_id" => option_id},
        socket
      ) do
    selected_options =
      update_selected_options(socket.assigns.selected_options, category_id, option_id)

    {:noreply, assign(socket, selected_options: selected_options)}
  end

  defp update_selected_options(_selected_options, _category_id, _option_id) do
  end
end
