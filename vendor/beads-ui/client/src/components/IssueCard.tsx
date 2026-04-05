import type { Issue } from "../lib/types";

const PRIORITY_COLORS: Record<number, string> = {
  0: "var(--priority-0)",
  1: "var(--priority-1)",
  2: "var(--priority-2)",
  3: "var(--priority-3)",
  4: "var(--priority-4)",
};

const TYPE_ICONS: Record<string, string> = {
  bug: "\u{1F41B}",
  feature: "\u2B50",
  task: "\u{1F4CB}",
  epic: "\u{1F3D4}",
  chore: "\u{1F527}",
};

const TYPE_COLORS: Record<string, { bg: string; text: string }> = {
  bug: { bg: "rgba(239,68,68,0.1)", text: "var(--type-bug)" },
  feature: { bg: "rgba(99,102,241,0.1)", text: "var(--type-feature)" },
  task: { bg: "rgba(120,113,108,0.1)", text: "var(--type-task)" },
  epic: { bg: "rgba(168,85,247,0.1)", text: "var(--type-epic)" },
  chore: { bg: "rgba(120,113,108,0.1)", text: "var(--type-chore)" },
};

const AVATAR_COLORS = [
  "#E57373", "#F06292", "#BA68C8", "#9575CD",
  "#7986CB", "#64B5F6", "#4FC3F7", "#4DD0E1",
  "#4DB6AC", "#81C784", "#AED581", "#FFB74D",
];

function getInitials(name: string): string {
  const parts = name.trim().split(/\s+/);
  if (parts.length >= 2) return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  return name.slice(0, 2).toUpperCase();
}

function getAvatarColor(name: string): string {
  let hash = 0;
  for (let i = 0; i < name.length; i++) hash = name.charCodeAt(i) + ((hash << 5) - hash);
  return AVATAR_COLORS[Math.abs(hash) % AVATAR_COLORS.length];
}

export function IssueCard({
  issue,
  onClick,
  dimmed = false,
}: {
  issue: Issue;
  onClick: () => void;
  dimmed?: boolean;
}) {
  const priorityColor = PRIORITY_COLORS[issue.priority] ?? "var(--priority-4)";
  const typeInfo = TYPE_COLORS[issue.issue_type] ?? TYPE_COLORS.task;
  const typeIcon = TYPE_ICONS[issue.issue_type] ?? "\u{1F4CB}";

  return (
    <button
      onClick={onClick}
      className={`issue-card group w-full text-left relative cursor-pointer ${dimmed ? "issue-card--dimmed" : ""}`}
    >
      {/* Priority left strip */}
      <div
        className="absolute left-0 top-0 bottom-0"
        style={{
          width: "3px",
          backgroundColor: priorityColor,
          borderRadius: "var(--radius-md) 0 0 var(--radius-md)",
        }}
      />

      <div className="pl-4 pr-3 py-3">
        {/* Row 1: Issue ID + drag handle */}
        <div className="flex items-center justify-between mb-1">
          <span
            className="text-xs font-mono"
            style={{ color: "var(--text-muted)" }}
          >
            {issue.id}
          </span>
          <span
            className="issue-card__handle text-xs"
            style={{ color: "var(--text-muted)" }}
          >
            ⠿
          </span>
        </div>

        {/* Row 2: Title */}
        <p
          className="text-sm font-medium line-clamp-2 mb-2"
          style={{ color: "var(--text-primary)" }}
        >
          {issue.title}
        </p>

        {/* Row 3: Type badge + assignee avatar */}
        <div className="flex items-center justify-between">
          <span
            className="inline-flex items-center gap-1 px-1.5 py-0.5 text-xs"
            style={{
              backgroundColor: typeInfo.bg,
              color: typeInfo.text,
              borderRadius: "var(--radius-sm)",
            }}
          >
            <span className="text-[10px]">{typeIcon}</span>
            {issue.issue_type}
          </span>

          {issue.assignee && (
            <div
              className="flex items-center justify-center rounded-full text-[10px] font-bold shrink-0"
              style={{
                width: "24px",
                height: "24px",
                backgroundColor: getAvatarColor(issue.assignee),
                color: "var(--text-inverse)",
              }}
              title={issue.assignee}
            >
              {getInitials(issue.assignee)}
            </div>
          )}
        </div>
      </div>
    </button>
  );
}
