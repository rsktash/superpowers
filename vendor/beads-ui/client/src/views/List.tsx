import { useState, useMemo, useEffect, useRef } from "react";
import { FixedSizeList as VirtualList } from "react-window";
import { useSubscription } from "../hooks/use-subscription";
import { useSearch } from "../hooks/use-search";
import { StatusBadge } from "../components/StatusBadge";
import { PriorityBadge } from "../components/PriorityBadge";
import { TypeBadge } from "../components/TypeBadge";
import type { Issue } from "../lib/types";

type GroupBy = "flat" | "status" | "type";

function FilterBar({
  statusFilter,
  setStatusFilter,
  typeFilter,
  setTypeFilter,
  groupBy,
  setGroupBy,
  searchQuery,
  setSearchQuery,
}: {
  statusFilter: string;
  setStatusFilter: (v: string) => void;
  typeFilter: string;
  setTypeFilter: (v: string) => void;
  groupBy: GroupBy;
  setGroupBy: (v: GroupBy) => void;
  searchQuery: string;
  setSearchQuery: (v: string) => void;
}) {
  return (
    <div className="flex items-center gap-3 mb-4 flex-wrap">
      <input
        type="text"
        placeholder="Search issues..."
        value={searchQuery}
        onChange={(e) => setSearchQuery(e.target.value)}
        className="px-3 py-1.5 text-sm border border-stone-300 rounded bg-white focus:outline-none focus:ring-2 focus:ring-blue-500 w-64"
      />
      <select
        value={statusFilter}
        onChange={(e) => setStatusFilter(e.target.value)}
        className="px-2 py-1.5 text-sm border border-stone-300 rounded bg-white"
      >
        <option value="all">All statuses</option>
        <option value="open">Open</option>
        <option value="in_progress">In Progress</option>
        <option value="blocked">Blocked</option>
        <option value="closed">Closed</option>
      </select>
      <select
        value={typeFilter}
        onChange={(e) => setTypeFilter(e.target.value)}
        className="px-2 py-1.5 text-sm border border-stone-300 rounded bg-white"
      >
        <option value="all">All types</option>
        <option value="epic">Epic</option>
        <option value="feature">Feature</option>
        <option value="task">Task</option>
        <option value="bug">Bug</option>
        <option value="chore">Chore</option>
      </select>
      <select
        value={groupBy}
        onChange={(e) => setGroupBy(e.target.value as GroupBy)}
        className="px-2 py-1.5 text-sm border border-stone-300 rounded bg-white"
      >
        <option value="flat">No grouping</option>
        <option value="status">Group by status</option>
        <option value="type">Group by type</option>
      </select>
    </div>
  );
}

function IssueRow({
  issue,
  selected,
  onClick,
}: {
  issue: Issue;
  selected: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={`w-full flex items-center gap-3 px-4 py-2 text-sm border-b border-stone-100 hover:bg-stone-50 transition-colors ${
        selected ? "bg-blue-50 border-l-2 border-l-blue-500" : ""
      }`}
    >
      <span className="font-mono text-xs text-stone-400 w-32 shrink-0 text-left">
        {issue.id}
      </span>
      <StatusBadge status={issue.status} />
      <PriorityBadge priority={issue.priority} />
      <span className="flex-1 text-left truncate">{issue.title}</span>
      <TypeBadge type={issue.issue_type} />
      <span className="text-xs text-stone-400 w-24 text-right shrink-0">
        {issue.assignee || "—"}
      </span>
    </button>
  );
}

export function List() {
  const { issues: allIssues, loading } = useSubscription("all-issues");
  const [statusFilter, setStatusFilter] = useState("all");
  const [typeFilter, setTypeFilter] = useState("all");
  const [groupBy, setGroupBy] = useState<GroupBy>("flat");
  const { query, setQuery, results: searchResults } = useSearch(allIssues);
  const [selectedIndex, setSelectedIndex] = useState(0);
  const listRef = useRef<VirtualList>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const [containerHeight, setContainerHeight] = useState(600);

  const filtered = useMemo(() => {
    let items = searchResults;
    if (statusFilter !== "all")
      items = items.filter((i) => i.status === statusFilter);
    if (typeFilter !== "all")
      items = items.filter((i) => i.issue_type === typeFilter);
    items.sort(
      (a, b) =>
        a.priority - b.priority ||
        new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime(),
    );
    return items;
  }, [searchResults, statusFilter, typeFilter]);

  // Measure container height for virtual list
  useEffect(() => {
    if (!containerRef.current) return;
    const observer = new ResizeObserver((entries) => {
      for (const entry of entries) {
        setContainerHeight(entry.contentRect.height);
      }
    });
    observer.observe(containerRef.current);
    return () => observer.disconnect();
  }, []);

  // Keyboard navigation
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (
        e.target instanceof HTMLInputElement ||
        e.target instanceof HTMLTextAreaElement ||
        e.target instanceof HTMLSelectElement
      )
        return;
      if (e.key === "j")
        setSelectedIndex((i) => Math.min(i + 1, filtered.length - 1));
      if (e.key === "k") setSelectedIndex((i) => Math.max(i - 1, 0));
      if (e.key === "Enter" && filtered[selectedIndex]) {
        window.location.hash = `#/detail/${filtered[selectedIndex].id}`;
      }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [filtered, selectedIndex]);

  // Scroll selected into view
  useEffect(() => {
    listRef.current?.scrollToItem(selectedIndex, "smart");
  }, [selectedIndex]);

  // Reset selection when filter changes
  useEffect(() => {
    setSelectedIndex(0);
  }, [statusFilter, typeFilter, query]);

  if (loading) return <div className="p-6 text-stone-400">Loading...</div>;

  const ROW_HEIGHT = 40;

  return (
    <div className="p-6 h-full flex flex-col">
      <h1 className="text-xl font-bold text-stone-800 mb-4">Issues</h1>
      <FilterBar
        statusFilter={statusFilter}
        setStatusFilter={setStatusFilter}
        typeFilter={typeFilter}
        setTypeFilter={setTypeFilter}
        groupBy={groupBy}
        setGroupBy={setGroupBy}
        searchQuery={query}
        setSearchQuery={setQuery}
      />
      <div className="text-xs text-stone-400 mb-2">
        {filtered.length} issues
      </div>
      <div
        ref={containerRef}
        className="flex-1 border border-stone-200 rounded bg-white overflow-hidden"
      >
        {filtered.length === 0 ? (
          <p className="text-sm text-stone-400 p-8 text-center">
            No issues match your filters
          </p>
        ) : (
          <VirtualList
            ref={listRef}
            height={containerHeight}
            itemCount={filtered.length}
            itemSize={ROW_HEIGHT}
            width="100%"
          >
            {({ index, style }) => (
              <div style={style}>
                <IssueRow
                  issue={filtered[index]}
                  selected={index === selectedIndex}
                  onClick={() => {
                    setSelectedIndex(index);
                    window.location.hash = `#/detail/${filtered[index].id}`;
                  }}
                />
              </div>
            )}
          </VirtualList>
        )}
      </div>
    </div>
  );
}
