import { useState, useCallback, useEffect } from "react";
import { Markdown } from "./Markdown";

interface SectionEditorProps {
  label: string;
  value: string;
  placeholder?: string;
  onSave: (value: string) => Promise<unknown>;
}

export function SectionEditor({
  label,
  value,
  placeholder,
  onSave,
}: SectionEditorProps) {
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(value);
  const [tab, setTab] = useState<"edit" | "preview">("edit");
  const [saving, setSaving] = useState(false);

  // Sync draft with external value when not editing
  useEffect(() => {
    if (!editing) setDraft(value);
  }, [value, editing]);

  const handleSave = useCallback(async () => {
    setSaving(true);
    try {
      await onSave(draft);
      setEditing(false);
      setTab("edit");
    } finally {
      setSaving(false);
    }
  }, [draft, onSave]);

  const handleCancel = useCallback(() => {
    setDraft(value);
    setEditing(false);
    setTab("edit");
  }, [value]);

  // Keyboard shortcuts
  useEffect(() => {
    if (!editing) return;
    const handler = (e: KeyboardEvent) => {
      if (e.key === "s" && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        handleSave();
      }
      if (e.key === "Escape") {
        e.preventDefault();
        handleCancel();
      }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [editing, handleSave, handleCancel]);

  if (!editing) {
    return (
      <div className="group">
        <div className="flex items-center justify-between mb-1">
          <h3 className="text-xs font-semibold text-stone-500 uppercase tracking-wide">
            {label}
          </h3>
          <button
            onClick={() => setEditing(true)}
            className="opacity-0 group-hover:opacity-100 text-stone-400 hover:text-stone-600 transition-opacity"
            title={`Edit ${label}`}
          >
            <svg
              className="w-4 h-4"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
              />
            </svg>
          </button>
        </div>
        {value ? (
          <Markdown content={value} />
        ) : (
          <p className="text-sm text-stone-400 italic">
            {placeholder || `Add ${label.toLowerCase()}...`}
          </p>
        )}
      </div>
    );
  }

  return (
    <div className="border border-blue-300 rounded-lg p-3 bg-blue-50/30">
      <div className="flex items-center justify-between mb-2">
        <h3 className="text-xs font-semibold text-stone-500 uppercase tracking-wide">
          {label}
        </h3>
        <div className="flex border border-stone-300 rounded overflow-hidden text-xs">
          <button
            onClick={() => setTab("edit")}
            className={`px-2 py-1 ${tab === "edit" ? "bg-stone-200 font-medium" : "bg-white"}`}
          >
            Edit
          </button>
          <button
            onClick={() => setTab("preview")}
            className={`px-2 py-1 ${tab === "preview" ? "bg-stone-200 font-medium" : "bg-white"}`}
          >
            Preview
          </button>
        </div>
      </div>
      {tab === "edit" ? (
        <textarea
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          rows={10}
          className="w-full p-2 text-sm font-mono border border-stone-300 rounded bg-white resize-y focus:outline-none focus:ring-2 focus:ring-blue-500"
          autoFocus
        />
      ) : (
        <div className="p-2 bg-white border border-stone-300 rounded min-h-[160px]">
          <Markdown content={draft} />
        </div>
      )}
      <div className="flex items-center justify-end gap-2 mt-2">
        <span className="text-xs text-stone-400 mr-auto">
          Cmd+S to save, Esc to cancel
        </span>
        <button
          onClick={handleCancel}
          className="px-3 py-1 text-sm text-stone-600 hover:bg-stone-200 rounded"
        >
          Cancel
        </button>
        <button
          onClick={handleSave}
          disabled={saving}
          className="px-3 py-1 text-sm bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
        >
          {saving ? "Saving..." : "Save"}
        </button>
      </div>
    </div>
  );
}
