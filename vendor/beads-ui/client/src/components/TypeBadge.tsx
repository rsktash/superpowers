const TYPE_STYLES: Record<string, string> = {
  epic: "bg-purple-100 text-purple-800",
  feature: "bg-indigo-100 text-indigo-800",
  bug: "bg-red-100 text-red-800",
  task: "bg-stone-100 text-stone-800",
  chore: "bg-stone-100 text-stone-600",
};

export function TypeBadge({ type }: { type: string }) {
  return (
    <span
      className={`inline-flex items-center px-2 py-0.5 rounded text-xs font-medium ${TYPE_STYLES[type] || "bg-stone-100 text-stone-800"}`}
    >
      {type}
    </span>
  );
}
