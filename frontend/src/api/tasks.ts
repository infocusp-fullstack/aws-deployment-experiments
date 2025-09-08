import axios from 'axios';

const BASE_URL = 'http://127.0.0.1:8000/todos';

export interface Task {
    id: number;
    name: string;
    completed: boolean;
    due_date: string;
    description?: string;
    priority: string;
}

export async function fetchTasks(): Promise<Task[]> {
    const response = await axios.get<Task[]>(BASE_URL);
    console.log("Fetch Tasks Response:", response.data);
    return response.data;
}

export async function addTask(name: string, description: string | any, priority: string, due_date: Date): Promise<Task> {
    console.log("Adding Task:", { name, description, priority, due_date });
    const response = await axios.post<Task>(BASE_URL, { name, description, priority, due_date, completed: false });
    console.log("Add Task Response:", response.data);
    return response.data;
}