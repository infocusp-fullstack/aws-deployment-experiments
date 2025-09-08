"use client";

import { useMemo } from "react";
import { format, isSameDay, parseISO } from "date-fns";
import type { Task } from "@/lib/types";
import { useTasks } from "@/hooks/use-tasks";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { ScrollArea } from "@/components/ui/scroll-area";

interface TaskCalendarProps {
  onEditTask: (task: Task) => void;
  onViewTask: (task: Task) => void;
}

const priorityBadgeVariant = {
  High: "destructive",
  Medium: "warning",
  Low: "outline",
} as const;

function DayWithTasks({
  date,
  tasks,
  onViewTask,
}: {
  date: Date;
  tasks: Task[];
  onViewTask: (task: Task) => void;
}) {
  const tasksForDay = useMemo(() =>
    tasks.filter((task) => task?.due_date && isSameDay(parseISO(task.due_date), date)),
    [tasks, date]
  );

  return (
    <div className="flex flex-col h-full">
      <time
        dateTime={date.toISOString()}
        className="h-6 flex items-center justify-center"
      >
        {format(date, "d")}
      </time>
      <ScrollArea className="flex-1">
        <div className="flex flex-col gap-1 p-1">
          {tasksForDay.map((task) => (
            <button
              key={task.id}
              onClick={() => onViewTask(task)}
              className={cn(
                "p-1 rounded-sm text-xs w-full text-left text-white",
                task.priority === "High" && "bg-red-500",
                task.priority === "Medium" && "bg-yellow-500",
                task.priority === "Low" && "bg-blue-500",
                !task.priority && "bg-gray-500",
                task.completed && "opacity-60 line-through"
              )}
            >
              {task.name}
            </button>
          ))}
        </div>
      </ScrollArea>
    </div>
  );
}

export function TaskCalendar({ onEditTask, onViewTask }: TaskCalendarProps) {
  const { tasks } = useTasks();

  const CustomDay = useMemo(() => {
    return function Day({
      date,
      ...props
    }: {
      date: Date;
      displayMonth: Date;
    }) {
      return <DayWithTasks date={date} tasks={tasks} onViewTask={onViewTask} />;
    };
  }, [tasks, onViewTask]);

  return (
    <div className="rounded-lg border">
      <Calendar
        components={{
          Day: CustomDay,
        }}
        classNames={{
          months: "w-full",
          month: "w-full space-y-0",
          table: "w-full border-collapse",
          head_row: "flex w-full",
          head_cell:
            "w-full text-muted-foreground font-normal text-[0.8rem] border-b border-r p-2",
          row: "flex w-full border-b",
          cell: "w-full h-32 text-center text-sm p-0 relative border-r last:border-r-0 [&:has([aria-selected].day-range-end)]:rounded-r-md [&:has([aria-selected].day-outside)]:bg-accent/50 [&:has([aria-selected])]:bg-accent first:[&:has([aria-selected])]:rounded-l-md last:[&:has([aria-selected])]:rounded-r-md focus-within:relative focus-within:z-20",
          day: "w-full h-full p-0 font-normal aria-selected:opacity-100",
          day_selected:
            "bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground focus:bg-primary focus:text-primary-foreground",
          day_today: "bg-accent text-accent-foreground",
          day_outside:
            "day-outside text-muted-foreground opacity-50 aria-selected:bg-accent/50 aria-selected:text-muted-foreground",
          day_disabled: "text-muted-foreground opacity-50",
          caption: "flex justify-center pt-1 relative items-center mb-4",
          caption_label: "text-xl font-medium",
        }}
      />
    </div>
  );
}
