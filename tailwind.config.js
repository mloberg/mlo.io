const _ = require("lodash");

module.exports = {
  purge: [
    "./src/**/*.html",
    "./src/**/*.md",
    "./assets/**/*.js",
  ],
  theme: {
    heroes: [
      "main",
      "i6VBVfcerso",
      "znT2Mwt9ypo",
      "hFzIoD0Fi8",
      "jb1Mc1lv8X0",
      // additional hero images here
    ],
    fontFamily: {
      title: ["Raleway", "sans-serif"],
      sans: [
        "Montserrat",
        "-apple-system",
        "BlinkMacSystemFont",
        "Segoe UI",
        "Roboto",
        "Helvetica Neue",
        "Arial",
        "Noto Sans",
        "sans-serif",
      ],
    },
    extend: {
      screens: {
        "dark": {"raw": "(prefers-color-scheme: dark)"},
      },
    },
  },
  variants: {},
  plugins: [
    require("tailwindcss-skip-link")(),
    function({ addComponents, theme }) {
      const screens = theme("screens", {});
      _.map(theme("heroes", []), hero => {
        const mediaQueries = _.map(screens, (width, name) => {
          return {
            [`@media (min-width: ${width})`]: {
              [`.hero-${hero}`]: {
                'background-image': `url("/images/hero/${hero}-${name}.jpg")`,
              },
            },
          };
        });

        addComponents([
          { [`.hero-${hero}`]: { 'background-image': `url("/images/hero/${hero}.jpg")` } },
          ...mediaQueries
        ]);
      });
    },
  ],
};
