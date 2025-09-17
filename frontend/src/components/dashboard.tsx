"use client";

import { useState } from "react";
import {
  Calendar,
  LayoutGrid,
  List,
  Plus,
} from "lucide-react";
import type { Task } from "@/lib/types";
import { Button } from "@/components/ui/button";
import {
  SidebarProvider,
  Sidebar,
  SidebarHeader,
  SidebarContent,
  SidebarTrigger,
  SidebarMenu,
  SidebarMenuItem,
  SidebarMenuButton,
  SidebarInset,
} from "@/components/ui/sidebar";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Logo } from "@/components/logo";
import { TaskList } from "@/components/task-list";
import { TaskForm } from "@/components/task-form";
import { DeleteTaskDialog } from "@/components/delete-task-dialog";
import { TaskCalendar } from "@/components/task-calendar";
import { TaskDetailDialog } from "@/components/task-detail-dialog";

export function Dashboard() {
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [taskToEdit, setTaskToEdit] = useState<Task | undefined>(undefined);
  const [taskToDelete, setTaskToDelete] = useState<Task | null>(null);
  const [taskToView, setTaskToView] = useState<Task | null>(null);

  const handleAddTask = () => {
    setTaskToEdit(undefined);
    setIsFormOpen(true);
  };

  const handleEditTask = (task: Task) => {
    setTaskToEdit(task);
    setIsFormOpen(true);
  };

  const handleDeleteTask = (task: Task) => {
    setTaskToDelete(task);
  };

  const handleViewTask = (task: Task) => {
    setTaskToView(task);
  };
  
  const handleEditFromDetail = (task: Task) => {
    setTaskToView(null);
    handleEditTask(task);
  };

  return (
    <SidebarProvider>
      <Sidebar>
        <SidebarHeader>
          <Logo />
        </SidebarHeader>
        <SidebarContent>
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton isActive>
                <LayoutGrid />
                <span>Dashboard</span>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarContent>
      </Sidebar>
      <SidebarInset>
        <main className="flex h-full flex-col">
          <header className="flex items-center justify-between border-b p-4">
            <div className="flex items-center gap-4">
              <SidebarTrigger />
              <h1 className="text-xl font-semibold">Dashboard</h1>
            </div>
            <Button onClick={handleAddTask}>
              <Plus className="mr-2" />
              Add Task
            </Button>
          </header>
          <div className="flex-1 overflow-auto p-4 md:p-6">
            <Tabs defaultValue="calendar">
              <TabsList className="mb-4">
                <TabsTrigger value="list">
                  <List className="mr-2" />
                  List View
                </TabsTrigger>
                <TabsTrigger value="calendar">
                  <Calendar className="mr-2" />
                  Calendar View
                </TabsTrigger>
              </TabsList>
              <TabsContent value="list">
                <TaskList
                  onEditTask={handleEditTask}
                  onDeleteTask={handleDeleteTask}
                  onViewTask={handleViewTask}
                />
              </TabsContent>
              <TabsContent value="calendar">
                <TaskCalendar onEditTask={handleEditTask} onViewTask={handleViewTask} />
              </TabsContent>
            </Tabs>
          </div>
        </main>
      </SidebarInset>

      <TaskForm
        key={taskToEdit?.id}
        open={isFormOpen}
        onOpenChange={setIsFormOpen}
        task={taskToEdit}
      />

      <DeleteTaskDialog
        open={!!taskToDelete}
        onOpenChange={(open) => !open && setTaskToDelete(null)}
        task={taskToDelete}
        onConfirm={() => setTaskToDelete(null)}
      />

      <TaskDetailDialog
        open={!!taskToView}
        onOpenChange={(open) => !open && setTaskToView(null)}
        task={taskToView}
        onEdit={handleEditFromDetail}
      />
    </SidebarProvider>
  );
}
