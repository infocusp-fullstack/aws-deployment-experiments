import { CheckCircle2 } from "lucide-react";

export function Logo() {
  return (
    <div className="flex items-center gap-2 p-2 font-semibold text-lg">
      <CheckCircle2 className="h-6 w-6 text-primary" />
      <span className="group-data-[collapsible=icon]:hidden">Infocusp.Todo</span>
    </div>
  );
}
