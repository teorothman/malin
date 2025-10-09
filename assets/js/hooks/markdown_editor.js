import EasyMDE from "easymde";

export default {
  mounted() {
    // Get the textarea element
    const textarea = this.el.querySelector("textarea");

    if (!textarea) {
      console.error("MarkdownEditor hook: textarea not found");
      return;
    }

    // Initialize EasyMDE
    this.editor = new EasyMDE({
      element: textarea,
      spellChecker: false,
      autosave: {
        enabled: true,
        uniqueId: textarea.id || "markdown-editor",
        delay: 1000,
      },
      placeholder: "Write your post content in Markdown...",
      status: ["autosave", "lines", "words"],
      minHeight: "400px",
      toolbar: [
        "bold",
        "italic",
        "heading",
        "|",
        "quote",
        "unordered-list",
        "ordered-list",
        "|",
        "link",
        "image",
        "|",
        "preview",
        "side-by-side",
        "fullscreen",
        "|",
        "guide",
      ],
    });

    // Sync editor content with textarea (but don't trigger LiveView events)
    this.editor.codemirror.on("change", () => {
      const value = this.editor.value();
      // Update the textarea value so LiveView can see it on submit
      textarea.value = value;
      // Don't dispatch input events to avoid re-renders
    });

    // Handle LiveView updates (if the value is changed externally)
    this.handleEvent = (event) => {
      if (event.type === "update") {
        this.editor.value(event.value);
      }
    };
  },

  updated() {
    // Handle updates from LiveView if needed
    const textarea = this.el.querySelector("textarea");
    if (textarea && this.editor && textarea.value !== this.editor.value()) {
      this.editor.value(textarea.value);
    }
  },

  destroyed() {
    // Clean up the editor when the component is removed
    if (this.editor) {
      this.editor.toTextArea();
      this.editor = null;
    }
  },
};
