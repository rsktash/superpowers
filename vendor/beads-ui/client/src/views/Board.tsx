import { useSubscription } from "../hooks/use-subscription";
import { IssueCard } from "../components/IssueCard";
import type { Issue } from "../lib/types";

function Column({
  title,
  issues,
  color,
  onCardClick,
}: {
  title: string;
  issues: Issue[];
  color: string;
  onCardClick: (id: string) => void;
}) {
  return (
    <div className="flex-1 min-w-[280px] max-w-[360px]">
      <div className="flex items-center gap-2 mb-3 px-1">
        <div className={`w-2 h-2 rounded-full ${color}`} />
        <h2 className="text-sm font-semibold text-stone-700">{title}</h2>
        <span className="text-xs text-stone-400 ml-auto">{issues.length}</span>
      </div>
      <div className="space-y-2 overflow-y-auto max-h-[calc(100vh-120px)] pr-1">
        {issues.map((issue) => (
          <IssueCard
            key={issue.id}
            issue={issue}
            onClick={() => onCardClick(issue.id)}
          />
        ))}
        {issues.length === 0 && (
          <p className="text-xs text-stone-400 text-center py-8">No issues</p>
        )}
      </div>
    </div>
  );
}

export function Board() {
  const { issues: readyIssues, loading: l1 } = useSubscription("ready-issues");
  const { issues: inProgressIssues, loading: l2 } = useSubscription("in-progress-issues");
  const { issues: blockedIssues, loading: l3 } = useSubscription("blocked-issues");
  const { issues: closedIssues, loading: l4 } = useSubscription("closed-issues");

  const loading = l1 || l2 || l3 || l4;

  const navigateToDetail = (id: string) => {
    window.location.hash = `#/detail/${id}`;
  };

  if (loading) {
    return <div className="p-6 text-stone-400">Loading board...</div>;
  }

  return (
    <div className="p-6">
      <h1 className="text-xl font-bold text-stone-800 mb-6">Board</h1>
      <div className="flex gap-4 overflow-x-auto">
        <Column
          title="Open"
          issues={readyIssues}
          color="bg-blue-500"
          onCardClick={navigateToDetail}
        />
        <Column
          title="In Progress"
          issues={inProgressIssues}
          color="bg-amber-500"
          onCardClick={navigateToDetail}
        />
        <Column
          title="Blocked"
          issues={blockedIssues}
          color="bg-red-500"
          onCardClick={navigateToDetail}
        />
        <Column
          title="Closed"
          issues={closedIssues.slice(0, 50)}
          color="bg-green-500"
          onCardClick={navigateToDetail}
        />
      </div>
    </div>
  );
}
