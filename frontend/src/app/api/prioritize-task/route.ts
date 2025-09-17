import { NextRequest, NextResponse } from 'next/server';
import { ai } from '@/ai/genkit';
import { z } from 'genkit';

const PrioritizeTaskInputSchema = z.object({
  description: z.string().describe('The description of the task.'),
  due_date: z.string().describe('The due date of the task (YYYY-MM-DD).'),
});

const PrioritizeTaskOutputSchema = z.object({
  priority: z
    .enum(['High', 'Medium', 'Low'])
    .describe('The suggested priority level for the task.'),
  reason: z
    .string()
    .describe('The reasoning behind the suggested priority level.'),
});

const prompt = ai.definePrompt({
  name: 'prioritizeTaskPrompt',
  input: { schema: PrioritizeTaskInputSchema },
  output: { schema: PrioritizeTaskOutputSchema },
  prompt: `You are a task prioritization expert. Analyze the task description and due date to suggest a priority level (High, Medium, or Low).

Task Description: {{{description}}}
Due Date: {{{due_date}}}

Consider the urgency and importance of the task based on the description and how close the due date is.

Respond with the priority and a brief reason for the suggested priority.`,
});

const prioritizeTaskFlow = ai.defineFlow(
  {
    name: 'prioritizeTaskFlow',
    inputSchema: PrioritizeTaskInputSchema,
    outputSchema: PrioritizeTaskOutputSchema,
  },
  async input => {
    const { output } = await prompt(input);
    return output!;
  }
);

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const result = await prioritizeTaskFlow(body);
    return NextResponse.json(result);
  } catch (error) {
    console.error('Error prioritizing task:', error);
    return NextResponse.json(
      { error: 'Failed to prioritize task' },
      { status: 500 }
    );
  }
}
