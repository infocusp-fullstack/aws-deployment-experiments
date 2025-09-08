"use client";
import { useState, useMemo } from "react";
import {
  ArrowUpDown,
  MoreHorizontal,
  Eye,
} from "lucide-react";
import { format, parseISO } from "date-fns";

import type { Task, Priority } from "@/lib/types";
import { useTasks } from "@/hooks/use-tasks";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

interface TaskListProps {
  onEditTask: (task: Task) => void;
  onDeleteTask: (task: Task) => void;
  onViewTask: (task: Task) => void;
}

type SortKey = "title" | "dueDate" | "priority";
type SortDirection = "asc" | "desc";

const priorityOrder: Record<Priority, number> = {
  High: 3,
  Medium: 2,
  Low: 1,
};

const priorityBadgeVariant: Record<Priority, "destructive" | "warning" | "outline"> = {
  High: "destructive",
  Medium: "warning",
  Low: "outline",
};

export function TaskList({ onEditTask, onDeleteTask, onViewTask }: TaskListProps) {
  const { tasks, toggleComplete } = useTasks();
  const [sortKey, setSortKey] = useState<SortKey | null>("dueDate");
  const [sortDirection, setSortDirection] = useState<SortDirection>("asc");

  const handleSort = (key: SortKey) => {
    if (sortKey === key) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortKey(key);
      setSortDirection("asc");
    }
  };

  const sortedTasks = useMemo(() => {
    return [...tasks].sort((a, b) => {
      if (a.completed && !b.completed) return 1;
      if (!a.completed && b.completed) return -1;
      if (!sortKey) return 0;
      
      const dir = sortDirection === "asc" ? 1 : -1;

      switch (sortKey) {
        case "title":
          return a.title.localeCompare(b.title) * dir;
        case "dueDate":
          return (parseISO(a.dueDate).getTime() - parseISO(b.dueDate).getTime()) * dir;
        case "priority":
          const priorityA = a.priority ? priorityOrder[a.priority] : 0;
          const priorityB = b.priority ? priorityOrder[b.priority] : 0;
          return (priorityA - priorityB) * dir;
        default:
          return 0;
      }
    });
  }, [tasks, sortKey, sortDirection]);

  const SortableHeader = ({
    columnKey,
    children,
  }: {
    columnKey: SortKey;
    children: React.ReactNode;
  }) => (
    <TableHead>
      <Button
        variant="ghost"
        onClick={() => handleSort(columnKey)}
        className="px-0 hover:bg-transparent"
      >
        {children}
        <ArrowUpDown className="ml-2 h-4 w-4" />
      </Button>
    </TableHead>
  );

  return (
    <div className="rounded-lg border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-[50px]"></TableHead>
            <SortableHeader columnKey="title">Task</SortableHeader>
            <SortableHeader columnKey="priority">Priority</SortableHeader>
            <SortableHeader columnKey="dueDate">Due Date</SortableHeader>
            <TableHead className="w-[50px]">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {sortedTasks.length > 0 ? (
            sortedTasks.map((task) => (
              <TableRow key={task.id} data-state={task.completed ? "completed" : ""}>
                <TableCell>
                  <Checkbox
                    checked={task.completed}
                    onCheckedChange={() => toggleComplete(task.id)}
                    aria-label={`Mark task ${task.title} as ${task.completed ? 'incomplete' : 'complete'}`}
                  />
                </TableCell>
                <TableCell
                  className={cn(
                    "font-medium",
                    task.completed && "text-muted-foreground line-through"
                  )}
                >
                  {task.title}
                </TableCell>
                <TableCell>
                  {task.priority && (
                    <Badge variant={priorityBadgeVariant[task.priority]}>
                      {task.priority}
                    </Badge>
                  )}
                </TableCell>
                <TableCell
                  className={cn(task.completed && "text-muted-foreground")}
                >
                  {format(parseISO(task.dueDate), "MMM d, yyyy")}
                </TableCell>
                <TableCell>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" className="h-8 w-8 p-0">
                        <span className="sr-only">Open menu</span>
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                       <DropdownMenuItem onClick={() => onViewTask(task)}>
                        <Eye className="mr-2 h-4 w-4" />
                        View
                      </DropdownMenuItem>
                      <DropdownMenuItem onClick={() => onEditTask(task)}>
                        Edit
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem
                        onClick={() => onDeleteTask(task)}
                        className="text-destructive focus:text-destructive focus:bg-destructive/10"
                      >
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))
          ) : (
            <TableRow>
              <TableCell colSpan={5} className="h-24 text-center">
                No tasks yet. Add one to get started!
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
}
