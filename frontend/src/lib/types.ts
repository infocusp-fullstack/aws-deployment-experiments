export type Priority = "High" | "Medium" | "Low";

export interface Task {
  id: string;
  title: string;
  description?: string;
  dueDate: string; // Stored as YYYY-MM-DD string for easy serialization
  completed: boolean;
  priority?: Priority;
  priorityReason?: string;
}
