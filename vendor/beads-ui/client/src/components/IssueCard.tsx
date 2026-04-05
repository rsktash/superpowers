import { PriorityBadge } from "./PriorityBadge";
import { TypeBadge } from "./TypeBadge";
import type { Issue } from "../lib/types";

const TYPE_BORDER_COLORS: Record<string, string> = {
  epic: "#7C3AED",
  feature: "#6366F1",
  bug: "#EF4444",
  task: "#16A34A",
  chore: "#78716C",
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
  const borderColor = TYPE_BORDER_COLORS[issue.issue_type] ?? "#78716C";

  return (
    <button
      onClick={onClick}
      className={`issue-card group w-full text-left relative cursor-pointer ${dimmed ? "issue-card--dimmed" : ""}`}
      style={{ borderLeft: `3px solid ${borderColor}` }}
    >
      <div className="px-3.5 py-3">
        {/* Issue ID */}
        <div className="mb-1">
          <span
            className="font-mono text-xs"
            style={{ color: "var(--text-tertiary)" }}
          >
            {issue.id}
          </span>
        </div>

        {/* Title */}
        <p
          className="text-sm font-medium line-clamp-2 mb-2.5"
          style={{ color: "var(--text-primary)" }}
        >
          {issue.title}
        </p>

        {/* Type badge + Priority badge + Assignee avatar */}
        <div className="flex items-center gap-1.5">
          <TypeBadge type={issue.issue_type} />
          <PriorityBadge priority={issue.priority} />
          <div className="flex-1" />
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
