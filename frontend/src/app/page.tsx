import { Dashboard } from "@/components/dashboard";
import { TasksProvider } from "@/contexts/tasks-context";

export default function Home() {
  return (
    <TasksProvider>
      <Dashboard />
    </TasksProvider>
  );
}
