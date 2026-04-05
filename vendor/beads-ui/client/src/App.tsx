import { WsProvider } from "./lib/ws-context";

export function App() {
  return (
    <WsProvider>
      <div className="flex h-screen">
        <nav className="w-48 bg-stone-100 border-r border-stone-200 p-4">
          <h1 className="font-bold text-lg mb-4">Beads</h1>
          <ul className="space-y-1">
            <li>
              <a
                href="#/board"
                className="block px-2 py-1 rounded hover:bg-stone-200"
              >
                Board
              </a>
            </li>
            <li>
              <a
                href="#/list"
                className="block px-2 py-1 rounded hover:bg-stone-200"
              >
                List
              </a>
            </li>
          </ul>
        </nav>
        <main className="flex-1 p-6">
          <p className="text-stone-500">Loading...</p>
        </main>
      </div>
    </WsProvider>
  );
}
