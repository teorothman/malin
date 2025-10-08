// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/malin_web.ex",
    "../lib/malin_web/**/*.*ex",
    "../deps/ash_authentication_phoenix/**/*.*ex",
  ],
  theme: {
    extend: {
      colors: {
        brand: "hsl(0, 20%, 87%)",
        accent: "hsl(44, 63%, 41%)",
        accent2: "hsl(44, 63%, 31%)",
        selected: "hsl(215, 96%, 34%)",
      },
      fontFamily: {
        sans: ["Libre Franklin", "sans-serif"],
      },
      backgroundImage: {
        "hero-pattern": "url('/images/background-sunny.jpg')",
      },
      gridTemplateRows: {
        desktop: "min-content minmax(0, 1fr) 24px",
        admin: "min-content minmax(0, 1fr)",
        mobile: "48px minmax(0, 1fr) 0px",
        chat: "min-content minmax(0, 1fr) min-content",
        single: "minmax(0, 1fr)",
      },
      gridTemplateColumns: {
        main: "minmax(280px, 1fr) 2fr minmax(280px, 1fr)",
      },
      fontSize: {
        "2xs": ".625rem",
        header: "2.65rem",
        "header-sm": "2.25rem",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ]),
    ),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized");
      let values = {};
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"],
      ];
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
          let name = path.basename(file, ".svg") + suffix;
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
        });
      });
      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            let content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, "");
            let size = theme("spacing.6");
            if (name.endsWith("-mini")) {
              size = theme("spacing.5");
            } else if (name.endsWith("-micro")) {
              size = theme("spacing.4");
            }
            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              "-webkit-mask": `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              "mask-repeat": "no-repeat",
              "background-color": "currentColor",
              "vertical-align": "middle",
              display: "inline-block",
              width: size,
              height: size,
            };
          },
        },
        { values },
      );
    }),
  ],
};
