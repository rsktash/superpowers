const STATUS_STYLES: Record<string, string> = {
  open: "bg-blue-100 text-blue-800",
  in_progress: "bg-amber-100 text-amber-800",
  blocked: "bg-red-100 text-red-800",
  closed: "bg-green-100 text-green-800",
};

const STATUS_LABELS: Record<string, string> = {
  open: "Open",
  in_progress: "In Progress",
  blocked: "Blocked",
  closed: "Closed",
};

export function StatusBadge({ status }: { status: string }) {
  return (
    <span
      className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${STATUS_STYLES[status] || "bg-gray-100 text-gray-800"}`}
    >
      {STATUS_LABELS[status] || status}
    </span>
  );
}
