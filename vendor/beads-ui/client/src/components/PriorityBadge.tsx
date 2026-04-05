const PRIORITY_STYLES: Record<number, string> = {
  0: "text-red-600",
  1: "text-orange-500",
  2: "text-yellow-500",
  3: "text-gray-400",
  4: "text-gray-300",
};

const PRIORITY_LABELS: Record<number, string> = {
  0: "P0",
  1: "P1",
  2: "P2",
  3: "P3",
  4: "P4",
};

export function PriorityBadge({ priority }: { priority: number }) {
  return (
    <span
      className={`text-xs font-mono font-bold ${PRIORITY_STYLES[priority] || "text-gray-400"}`}
    >
      {PRIORITY_LABELS[priority] ?? `P${priority}`}
    </span>
  );
}
