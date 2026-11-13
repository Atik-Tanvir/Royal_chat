import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        darkBg: "#0B1512",
        darkCard: "#11221D",
        darkBorder: "#1C3830",
        emeraldPrimary: "#10B981",
        emeraldHover: "#059669",
        goldCoin: "#F59E0B",
        goldHover: "#D97706",
        gemCyan: "#00E5FF",
      },
    },
  },
  plugins: [],
};
export default config;
