import { useState, useEffect, type ReactNode } from "react";

function useHashRoute(): string {
  const [hash, setHash] = useState(window.location.hash || "#/board");
  useEffect(() => {
    const handler = () => setHash(window.location.hash || "#/board");
    window.addEventListener("hashchange", handler);
    return () => window.removeEventListener("hashchange", handler);
  }, []);
  return hash;
}

function NavLink({ href, label, active }: { href: string; label: string; active: boolean }) {
  return (
    <a
      href={href}
      className={`block px-3 py-1.5 rounded text-sm ${
        active
          ? "bg-stone-200 font-medium text-stone-900"
          : "text-stone-600 hover:bg-stone-100"
      }`}
    >
      {label}
    </a>
  );
}

export function Layout({
  children,
}: {
  children: (route: string) => ReactNode;
}) {
  const route = useHashRoute();

  return (
    <div className="flex h-screen bg-stone-50">
      <nav className="w-48 bg-stone-100 border-r border-stone-200 p-3 flex flex-col">
        <h1 className="font-bold text-lg px-3 py-2 text-stone-800">Beads</h1>
        <div className="space-y-0.5 mt-2">
          <NavLink href="#/board" label="Board" active={route.startsWith("#/board")} />
          <NavLink href="#/list" label="List" active={route.startsWith("#/list")} />
        </div>
      </nav>
      <main className="flex-1 overflow-auto">{children(route)}</main>
    </div>
  );
}
