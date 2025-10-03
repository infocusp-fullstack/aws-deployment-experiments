import axios from 'axios';
import type { Task, Priority } from '@/lib/types';

export async function fetchTasks(): Promise<Task[]> {
    const response = await axios.get<Task[]>("/api/todos");
    console.log("Fetch Tasks Response:", response.data);
    return response.data;
}

export async function addTask(name: string, description: string | any, priority: Priority, due_date: Date): Promise<Task> {
    console.log("Adding Task:", { name, description, priority, due_date });
    const response = await axios.post<Task>("/api/todos", { name, description, priority, due_date, completed: false });
    console.log("Add Task Response:", response.data);
    return response.data;
}

export async function updateTask(todoId: any, name: string, description: string | any, priority: Priority, due_date: Date, completed: boolean): Promise<Task> {
    console.log("Updating Task:", { name, description, priority, due_date, completed });
    const response = await axios.put<Task>(`/api/todos/${todoId}`, { name, description, priority, due_date, completed });
    console.log("Update Task Response:", response.data);
    return response.data;
}