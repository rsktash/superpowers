import { WsProvider } from "./lib/ws-context";
import { Layout } from "./components/Layout";
import { Board } from "./views/Board";

export function App() {
  return (
    <WsProvider>
      <Layout>
        {(route) => {
          if (
            route.startsWith("#/board") ||
            route === "" ||
            route === "#/" ||
            route === "#"
          )
            return <Board />;
          return (
            <div className="p-6 text-stone-400">
              View not implemented yet
            </div>
          );
        }}
      </Layout>
    </WsProvider>
  );
}
