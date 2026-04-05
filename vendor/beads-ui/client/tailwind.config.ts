import type { Config } from "tailwindcss";
import path from "path";
import typography from "@tailwindcss/typography";

const clientDir = path.resolve(import.meta.dirname);

export default {
  content: [
    path.join(clientDir, "src/**/*.{ts,tsx}"),
    path.join(clientDir, "index.html"),
  ],
  theme: {
    extend: {
      colors: {
        status: {
          open: "#3b82f6",
          in_progress: "#f59e0b",
          blocked: "#ef4444",
          closed: "#22c55e",
        },
        priority: {
          0: "#ef4444",
          1: "#f97316",
          2: "#eab308",
          3: "#9ca3af",
          4: "#d1d5db",
        },
      },
    },
  },
  plugins: [typography],
} satisfies Config;
