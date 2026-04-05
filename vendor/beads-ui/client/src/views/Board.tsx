import { useMemo, useState, useRef, useEffect } from "react";
import { useSubscription } from "../hooks/use-subscription";
import { IssueCard } from "../components/IssueCard";
import type { SubscriptionType } from "../lib/types";

const COLUMN_PAGE_SIZE = 20;

const STATUS_COLORS: Record<string, string> = {
  open: "var(--status-open)",
  in_progress: "var(--status-in-progress)",
  blocked: "var(--status-blocked)",
  closed: "var(--status-closed)",
};

function Column({
  title,
  subscriptionType,
  statusKey,
  onCardClick,
  isClosed = false,
}: {
  title: string;
  subscriptionType: SubscriptionType;
  statusKey: string;
  onCardClick: (id: string) => void;
  isClosed?: boolean;
}) {
  const [limit, setLimit] = useState(COLUMN_PAGE_SIZE);
  const params = useMemo(() => ({ limit, offset: 0 }), [limit]);
  const { issues, loading, total } = useSubscription(subscriptionType, params);
  const scrollRef = useRef<HTMLDivElement>(null);
  const [hasOverflow, setHasOverflow] = useState(false);

  const hasMore = total > issues.length;
  const remaining = total - issues.length;
  const dotColor = STATUS_COLORS[statusKey] ?? "var(--text-muted)";

  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    const check = () => setHasOverflow(el.scrollHeight > el.clientHeight);
    check();
    const observer = new ResizeObserver(check);
    observer.observe(el);
    return () => observer.disconnect();
  }, [issues.length]);

  return (
    <div
      className="flex-1 min-w-[280px] max-w-[360px] flex flex-col"
    >
      {/* Column header */}
      <div
        className="flex items-center gap-2 px-1 pb-3 sticky top-0 z-10"
        style={{
          borderBottom: "1px solid rgba(0,0,0,0.06)",
          marginBottom: "var(--space-3)",
          background: "var(--bg-base)",
        }}
      >
        <div
          className="rounded-full shrink-0"
          style={{
            width: "8px",
            height: "8px",
            backgroundColor: dotColor,
          }}
        />
        <h2
          className="text-sm font-semibold"
          style={{ color: "var(--text-primary)" }}
        >
          {title}
        </h2>
        <span
          className="text-xs px-1.5 py-0.5 rounded-full ml-auto"
          style={{
            backgroundColor: "rgba(0,0,0,0.05)",
            color: "var(--text-muted)",
            fontSize: "11px",
          }}
        >
          {loading ? "\u2026" : isClosed && total > issues.length ? `${issues.length} / ${total}` : total}
        </span>
      </div>

      {/* Card list */}
      <div
        ref={scrollRef}
        className="space-y-2 overflow-y-auto flex-1 pr-1 relative"
        style={{
          maxHeight: "calc(100vh - 160px)",
          maskImage: hasOverflow
            ? "linear-gradient(to bottom, transparent 0px, black 8px, black calc(100% - 8px), transparent 100%)"
            : undefined,
          WebkitMaskImage: hasOverflow
            ? "linear-gradient(to bottom, transparent 0px, black 8px, black calc(100% - 8px), transparent 100%)"
            : undefined,
        }}
      >
        {loading && issues.length === 0 && (
          <div className="py-8 text-center">
            <p className="text-xs" style={{ color: "var(--text-muted)" }}>
              Loading\u2026
            </p>
          </div>
        )}

        {!loading && issues.length === 0 && (
          <div
            className="py-8 text-center rounded-lg"
            style={{
              border: "2px dashed var(--text-muted)",
              opacity: 0.4,
              borderRadius: "var(--radius-md)",
            }}
          >
            <p className="text-xs" style={{ color: "var(--text-muted)" }}>
              No items
            </p>
          </div>
        )}

        {issues.map((issue) => (
          <IssueCard
            key={issue.id}
            issue={issue}
            onClick={() => onCardClick(issue.id)}
            dimmed={isClosed}
          />
        ))}

        {hasMore && (
          <button
            onClick={() => setLimit((l) => l + COLUMN_PAGE_SIZE)}
            className="w-full text-xs py-2 hover:underline"
            style={{
              color: "var(--text-secondary)",
              transition: "color 100ms ease",
            }}
          >
            Show {remaining} more\u2026
          </button>
        )}
      </div>
    </div>
  );
}

export function Board() {
  const navigateToDetail = (id: string) => {
    window.location.hash = `#/detail/${id}`;
  };

  return (
    <div className="p-6" style={{ background: "var(--bg-base)" }}>
      <h1
        className="text-xl font-bold mb-6"
        style={{ color: "var(--text-primary)" }}
      >
        Board
      </h1>
      <div className="flex gap-4 overflow-x-auto">
        <Column
          title="Open"
          subscriptionType="ready-issues"
          statusKey="open"
          onCardClick={navigateToDetail}
        />
        <Column
          title="In Progress"
          subscriptionType="in-progress-issues"
          statusKey="in_progress"
          onCardClick={navigateToDetail}
        />
        <Column
          title="Blocked"
          subscriptionType="blocked-issues"
          statusKey="blocked"
          onCardClick={navigateToDetail}
        />
        <Column
          title="Closed"
          subscriptionType="closed-issues"
          statusKey="closed"
          onCardClick={navigateToDetail}
          isClosed
        />
      </div>
    </div>
  );
}
