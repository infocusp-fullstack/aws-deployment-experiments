"use client";

import {
  createContext,
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from "react";
import { v4 as uuidv4 } from "uuid";
import type { Task, Priority } from "@/lib/types";

// Forcing uuid to be a client-side module
(uuidv4 as any).browser = true;

interface TasksContextType {
  tasks: Task[];
  addTask: (task: Omit<Task, "id" | "completed">) => void;
  updateTask: (task: Task) => void;
  deleteTask: (id: string) => void;
  toggleComplete: (id: string) => void;
}

export const TasksContext = createContext<TasksContextType | undefined>(
  undefined
);

interface TasksProviderProps {
  children: ReactNode;
}

const isBrowser = typeof window !== "undefined";

const initialTasks: Task[] = [
  {
    id: '1',
    title: "Design the new dashboard interface",
    description: "Create mockups and a prototype in Figma for the new dashboard layout.",
    dueDate: "2024-08-15",
    completed: false,
    priority: "High",
    priorityReason: "This is a critical path for the next release.",
  },
  {
    id: '2',
    title: "Develop the API for user authentication",
    description: "Set up endpoints for user login, registration, and session management.",
    dueDate: "2024-08-20",
    completed: false,
    priority: "High",
    priorityReason: "Authentication is a blocker for other features.",
  },
  {
    id: '3',
    title: "Write documentation for the new components",
    description: "Document props, usage examples, and best practices for the new UI library.",
    dueDate: "2024-08-25",
    completed: false,
    priority: "Medium",
    priorityReason: "Good documentation will speed up team onboarding.",
  },
   {
    id: '4',
    title: "Plan company offsite event",
    description: "Coordinate with vendors for location, catering, and activities.",
    dueDate: "2024-09-10",
    completed: true,
    priority: "Low",
    priorityReason: "Important for team morale but not an immediate product priority.",
  },
];


export function TasksProvider({ children }: TasksProviderProps) {
  const [tasks, setTasks] = useState<Task[]>(() => {
    if (!isBrowser) {
      return initialTasks;
    }
    try {
      const item = window.localStorage.getItem("infocusp-tasks");
      return item ? JSON.parse(item) : initialTasks;
    } catch (error) {
      console.error(error);
      return initialTasks;
    }
  });

  useEffect(() => {
    if (isBrowser) {
      try {
        window.localStorage.setItem("infocusp-tasks", JSON.stringify(tasks));
      } catch (error) {
        console.error(error);
      }
    }
  }, [tasks]);

  const addTask = useCallback(
    (taskData: Omit<Task, "id" | "completed">) => {
      const newTask: Task = {
        id: uuidv4(),
        ...taskData,
        completed: false,
      };
      setTasks((prevTasks) => [newTask, ...prevTasks]);
    },
    []
  );

  const updateTask = useCallback((updatedTask: Task) => {
    setTasks((prevTasks) =>
      prevTasks.map((task) =>
        task.id === updatedTask.id ? updatedTask : task
      )
    );
  }, []);

  const deleteTask = useCallback((id: string) => {
    setTasks((prevTasks) => prevTasks.filter((task) => task.id !== id));
  }, []);

  const toggleComplete = useCallback((id: string) => {
    setTasks((prevTasks) =>
      prevTasks.map((task) =>
        task.id === id ? { ...task, completed: !task.completed } : task
      )
    );
  }, []);

  const value = { tasks, addTask, updateTask, deleteTask, toggleComplete };

  return (
    <TasksContext.Provider value={value}>{children}</TasksContext.Provider>
  );
}
