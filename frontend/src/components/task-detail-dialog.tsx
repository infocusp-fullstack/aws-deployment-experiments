"use client";

import { format, parseISO } from "date-fns";
import { Calendar, Edit, Sparkles, Tag } from "lucide-react";

import type { Task, Priority } from "@/lib/types";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import { Separator } from "@/components/ui/separator";

interface TaskDetailDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  task: Task | null;
  onEdit: (task: Task) => void;
}

const priorityBadgeVariant = {
  "High": "destructive",
  "Medium": "warning",
  "Low": "outline",
} as const;


export function TaskDetailDialog({
  open,
  onOpenChange,
  task,
  onEdit,
}: TaskDetailDialogProps) {
  if (!task) {
    return null;
  }

  const handleEditClick = () => {
    onEdit(task);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>{task.name}</DialogTitle>
          <DialogDescription>
            {task.completed ? "Completed" : "In progress"}
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-4 py-4">
          {task.description && (
            <p className="text-sm text-muted-foreground">{task.description}</p>
          )}

          <Separator />

          <div className="grid grid-cols-[80px_1fr] items-center gap-4 text-sm">
            <div className="flex items-center gap-2 text-muted-foreground">
              <Calendar className="h-4 w-4" />
              <span>Due Date</span>
            </div>
            <span>{format(parseISO(task.due_date), "PPP")}</span>

            {task.priority && (
              <>
                <div className="flex items-center gap-2 text-muted-foreground">
                  <Tag className="h-4 w-4" />
                  <span>Priority</span>
                </div>
                <Badge variant={priorityBadgeVariant[task.priority]}>{task.priority}</Badge>
              </>
            )}
          </div>

          {/* {task.priorityReason && (
            <div className="rounded-md border bg-accent/50 p-3 text-sm">
              <div className="flex items-center gap-2 font-semibold mb-2">
                <Sparkles className="h-4 w-4 text-primary" />
                <span>AI Priority Suggestion</span>
              </div>
              <p className="text-accent-foreground/80">{task.priorityReason}</p>
            </div>
          )} */}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={handleEditClick}>
            <Edit className="mr-2 h-4 w-4" />
            Edit
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
