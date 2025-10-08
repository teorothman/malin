const FlodeskForm = {
  mounted() {
    const formId = this.el.dataset.formId;
    const containerId = `#${this.el.id}`;

    // Function to initialize the form
    const initForm = () => {
      if (window.fd && typeof window.fd === 'function') {
        window.fd('form', {
          formId: formId,
          containerEl: containerId
        });
      }
    };

    // Check if Flodesk is already loaded
    if (window.fd && typeof window.fd === 'function') {
      initForm();
    } else {
      // Poll for Flodesk to be available (it loads async)
      const checkFlodesk = setInterval(() => {
        if (window.fd && typeof window.fd === 'function') {
          clearInterval(checkFlodesk);
          initForm();
        }
      }, 100);

      // Clear interval after 10 seconds to prevent infinite polling
      setTimeout(() => clearInterval(checkFlodesk), 10000);
    }
  }
};

export default FlodeskForm;
