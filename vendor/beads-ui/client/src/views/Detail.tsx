import { useState } from "react";
import { useSubscription } from "../hooks/use-subscription";
import { useMutation } from "../hooks/use-mutation";
import { StatusBadge } from "../components/StatusBadge";
import { TypeBadge } from "../components/TypeBadge";
import { SectionEditor } from "../components/SectionEditor";
import type { Issue } from "../lib/types";

function MetadataSidebar({
  issue,
  onUpdate,
}: {
  issue: Issue;
  onUpdate: ReturnType<typeof useMutation>;
}) {
  return (
    <aside className="w-72 shrink-0 border-l border-stone-200 p-4 space-y-4 bg-stone-50 overflow-y-auto">
      <div>
        <h3 className="text-xs font-semibold text-stone-500 uppercase mb-1">
          Status
        </h3>
        <select
          value={issue.status}
          onChange={(e) =>
            onUpdate.updateStatus(
              issue.id,
              e.target.value as "open" | "in_progress" | "closed",
            )
          }
          className="w-full px-2 py-1 text-sm border border-stone-300 rounded bg-white"
        >
          <option value="open">Open</option>
          <option value="in_progress">In Progress</option>
          <option value="closed">Closed</option>
        </select>
      </div>
      <div>
        <h3 className="text-xs font-semibold text-stone-500 uppercase mb-1">
          Priority
        </h3>
        <select
          value={issue.priority}
          onChange={(e) =>
            onUpdate.updatePriority(issue.id, Number(e.target.value))
          }
          className="w-full px-2 py-1 text-sm border border-stone-300 rounded bg-white"
        >
          {[0, 1, 2, 3, 4].map((p) => (
            <option key={p} value={p}>
              P{p}
            </option>
          ))}
        </select>
      </div>
      <div>
        <h3 className="text-xs font-semibold text-stone-500 uppercase mb-1">
          Type
        </h3>
        <TypeBadge type={issue.issue_type} />
      </div>
      <div>
        <h3 className="text-xs font-semibold text-stone-500 uppercase mb-1">
          Assignee
        </h3>
        <p className="text-sm text-stone-700">
          {issue.assignee || "Unassigned"}
        </p>
      </div>
      {issue.labels && issue.labels.length > 0 && (
        <div>
          <h3 className="text-xs font-semibold text-stone-500 uppercase mb-1">
            Labels
          </h3>
          <div className="flex flex-wrap gap-1">
            {issue.labels.map((l) => (
              <span key={l} className="px-2 py-0.5 text-xs bg-stone-200 rounded">
                {l}
              </span>
            ))}
          </div>
        </div>
      )}
      {/* Parent epic link */}
      {(issue.parent_id || (issue as any).parent) && (
        <div>
          <h3 className="text-xs font-semibold text-stone-500 uppercase mb-1">
            Parent
          </h3>
          <a
            href={`#/detail/${issue.parent_id || (issue as any).parent}`}
            className="flex items-center gap-1 text-xs text-blue-600 hover:underline"
          >
            <span className="font-mono">{issue.parent_id || (issue as any).parent}</span>
          </a>
        </div>
      )}
      {(() => {
        // Filter to only "blocks" deps where this issue depends on another (not parent-child, which is shown as Children)
        const blocksDeps = (issue.dependencies || []).filter(
          (dep: any) => dep.type === "blocks" && dep.issue_id === issue.id
        );
        if (blocksDeps.length === 0) return null;
        return (
          <div>
            <h3 className="text-xs font-semibold text-stone-500 uppercase mb-1">
              Blocked By
            </h3>
            <div className="space-y-1">
              {blocksDeps.map((dep: any) => (
                <a
                  key={dep.depends_on_id}
                  href={`#/detail/${dep.depends_on_id}`}
                  className="block text-xs font-mono text-blue-600 hover:underline px-1 py-0.5"
                >
                  {dep.depends_on_id}
                </a>
              ))}
            </div>
          </div>
        );
      })()}
      {issue.dependents && issue.dependents.length > 0 && (
        <div>
          <h3 className="text-xs font-semibold text-stone-500 uppercase mb-1">
            Children / Dependents
          </h3>
          <div className="space-y-1">
            {issue.dependents.map((dep) => (
              <a
                key={dep.id}
                href={`#/detail/${dep.id}`}
                className="block text-xs hover:bg-stone-100 rounded px-1 py-1.5 -mx-1 transition-colors"
              >
                <div className="flex items-center gap-1.5 mb-0.5">
                  <StatusBadge status={dep.status} />
                  <span className="font-mono text-stone-400">{dep.id}</span>
                </div>
                {dep.title && (
                  <p className="text-stone-700 text-xs leading-snug pl-0.5 line-clamp-2">{dep.title}</p>
                )}
              </a>
            ))}
          </div>
        </div>
      )}
    </aside>
  );
}

function CommentsSection({ issueId }: { issueId: string }) {
  const mutations = useMutation();
  const [newComment, setNewComment] = useState("");

  const handleAddComment = async () => {
    if (!newComment.trim()) return;
    await mutations.addComment(issueId, newComment.trim());
    setNewComment("");
  };

  return (
    <div>
      <h3 className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-2">
        Comments
      </h3>
      <div className="flex gap-2">
        <textarea
          value={newComment}
          onChange={(e) => setNewComment(e.target.value)}
          placeholder="Add a comment... (Ctrl+Enter to submit)"
          rows={3}
          className="flex-1 p-2 text-sm border border-stone-300 rounded bg-white resize-y focus:outline-none focus:ring-2 focus:ring-blue-500"
          onKeyDown={(e) => {
            if (e.key === "Enter" && (e.ctrlKey || e.metaKey))
              handleAddComment();
          }}
        />
      </div>
      <button
        onClick={handleAddComment}
        className="mt-2 px-3 py-1 text-sm bg-stone-200 hover:bg-stone-300 rounded"
      >
        Add Comment
      </button>
    </div>
  );
}

export function Detail({ issueId }: { issueId: string }) {
  const { issues, loading } = useSubscription("issue-detail", { id: issueId });
  const mutations = useMutation();
  const issue = issues[0];

  if (loading) return <div className="p-6 text-stone-400">Loading...</div>;
  if (!issue)
    return <div className="p-6 text-stone-400">Issue not found</div>;

  return (
    <div className="flex h-full">
      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {/* Breadcrumbs */}
        <div className="flex items-center gap-2 text-sm text-stone-400">
          <a href="#/list" className="hover:text-stone-600">
            List
          </a>
          <span>/</span>
          <span className="font-mono">{issue.id}</span>
        </div>

        {/* Title */}
        <h1 className="text-2xl font-bold text-stone-900">{issue.title}</h1>

        {/* Description */}
        <SectionEditor
          label="Description"
          value={issue.description || ""}
          onSave={(v) =>
            mutations.editText({
              id: issue.id,
              field: "description",
              value: v,
            })
          }
        />

        {/* Acceptance Criteria */}
        <SectionEditor
          label="Acceptance Criteria"
          value={issue.acceptance || ""}
          placeholder="Add acceptance criteria..."
          onSave={(v) =>
            mutations.editText({
              id: issue.id,
              field: "acceptance",
              value: v,
            })
          }
        />

        {/* Notes */}
        <SectionEditor
          label="Notes"
          value={issue.notes || ""}
          placeholder="Add notes..."
          onSave={(v) =>
            mutations.editText({ id: issue.id, field: "notes", value: v })
          }
        />

        {/* Design */}
        <SectionEditor
          label="Design"
          value={issue.design || ""}
          placeholder="Add design notes..."
          onSave={(v) =>
            mutations.editText({ id: issue.id, field: "design", value: v })
          }
        />

        {/* Children (epics only) */}
        {issue.issue_type === "epic" && issue.dependents && issue.dependents.length > 0 && (
          <div>
            <h3 className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-2">
              Children ({issue.closed_children ?? 0} / {issue.total_children ?? issue.dependents.length})
            </h3>
            <div className="space-y-1">
              {issue.dependents.map((child) => (
                <a
                  key={child.id}
                  href={`#/detail/${child.id}`}
                  className="flex items-center gap-2 px-2 py-1.5 rounded hover:bg-stone-100 transition-colors"
                  style={{ opacity: child.status === "closed" ? 0.6 : 1 }}
                >
                  <div
                    className="w-2 h-2 rounded-full shrink-0"
                    style={{
                      backgroundColor:
                        child.status === "open" ? "var(--status-open)" :
                        child.status === "in_progress" ? "var(--status-in-progress)" :
                        child.status === "blocked" ? "var(--status-blocked)" :
                        "var(--status-closed)",
                    }}
                  />
                  <span className="text-xs font-mono text-stone-400">{child.id}</span>
                  <span className="text-sm text-stone-700 truncate">{child.title}</span>
                </a>
              ))}
            </div>
          </div>
        )}

        {/* Comments */}
        <CommentsSection issueId={issue.id} />
      </div>

      {/* Metadata sidebar */}
      <MetadataSidebar issue={issue} onUpdate={mutations} />
    </div>
  );
}
