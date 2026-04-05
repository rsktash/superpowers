import type { Issue } from "../lib/types";
import { PriorityBadge } from "./PriorityBadge";
import { TypeBadge } from "./TypeBadge";

export function IssueCard({
  issue,
  onClick,
}: {
  issue: Issue;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className="w-full text-left p-3 bg-white rounded-lg border border-stone-200 hover:border-stone-300 hover:shadow-sm transition-all"
    >
      <div className="flex items-start justify-between gap-2 mb-1">
        <span className="text-xs font-mono text-stone-400">{issue.id}</span>
        <PriorityBadge priority={issue.priority} />
      </div>
      <p className="text-sm font-medium text-stone-900 mb-2 line-clamp-2">
        {issue.title}
      </p>
      <div className="flex items-center gap-2">
        <TypeBadge type={issue.issue_type} />
        {issue.assignee && (
          <span className="text-xs text-stone-500">{issue.assignee}</span>
        )}
      </div>
    </button>
  );
}
