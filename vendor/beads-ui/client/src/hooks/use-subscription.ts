import { useEffect, useState, useRef } from "react";
import { useWs } from "../lib/ws-context";
import type { Issue, SubscriptionType, PushEvent } from "../lib/types";

export function useSubscription(
  type: SubscriptionType,
  params?: Record<string, string | number | boolean>,
): { issues: Issue[]; loading: boolean } {
  const ws = useWs();
  const [issues, setIssues] = useState<Issue[]>([]);
  const [loading, setLoading] = useState(true);
  const itemsRef = useRef(new Map<string, Issue>());

  useEffect(() => {
    const subId = `sub-${type}-${Date.now()}`;
    itemsRef.current = new Map();
    setLoading(true);

    const cleanup = ws.onPush((event: PushEvent) => {
      if (event.id !== subId) return;

      if (event.type === "snapshot") {
        const map = new Map<string, Issue>();
        for (const issue of event.issues) map.set(issue.id, issue);
        itemsRef.current = map;
        setIssues(Array.from(map.values()));
        setLoading(false);
      } else if (event.type === "upsert") {
        itemsRef.current.set(event.issue.id, event.issue);
        setIssues(Array.from(itemsRef.current.values()));
      } else if (event.type === "delete") {
        itemsRef.current.delete(event.issue_id);
        setIssues(Array.from(itemsRef.current.values()));
      }
    });

    ws.subscribe({ id: subId, type, params });

    return () => {
      cleanup();
      ws.unsubscribe(subId);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [ws, type, JSON.stringify(params)]);

  return { issues, loading };
}
