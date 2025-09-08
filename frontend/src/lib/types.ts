export type Priority = "High" | "Medium" | "Low";

export interface Task {
  id: string;
  name: string;
  description?: string;
  due_date: string; // Stored as YYYY-MM-DD string for easy serialization
  completed: boolean;
  priority: string;
}
