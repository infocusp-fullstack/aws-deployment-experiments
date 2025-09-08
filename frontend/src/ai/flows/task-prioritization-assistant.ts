'use server';

/**
 * @fileOverview Task Prioritization Assistant AI agent.
 *
 * - prioritizeTask - A function that analyzes task descriptions and suggests priority levels.
 * - PrioritizeTaskInput - The input type for the prioritizeTask function.
 * - PrioritizeTaskOutput - The return type for the prioritizeTask function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const PrioritizeTaskInputSchema = z.object({
  description: z.string().describe('The description of the task.'),
  dueDate: z.string().describe('The due date of the task (YYYY-MM-DD).'),
});
export type PrioritizeTaskInput = z.infer<typeof PrioritizeTaskInputSchema>;

const PrioritizeTaskOutputSchema = z.object({
  priority: z
    .enum(['High', 'Medium', 'Low'])
    .describe('The suggested priority level for the task.'),
  reason: z
    .string()
    .describe('The reasoning behind the suggested priority level.'),
});
export type PrioritizeTaskOutput = z.infer<typeof PrioritizeTaskOutputSchema>;

export async function prioritizeTask(input: PrioritizeTaskInput): Promise<PrioritizeTaskOutput> {
  return prioritizeTaskFlow(input);
}

const prompt = ai.definePrompt({
  name: 'prioritizeTaskPrompt',
  input: {schema: PrioritizeTaskInputSchema},
  output: {schema: PrioritizeTaskOutputSchema},
  prompt: `You are a task prioritization expert. Analyze the task description and due date to suggest a priority level (High, Medium, or Low).

Task Description: {{{description}}}
Due Date: {{{dueDate}}}

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
    const {output} = await prompt(input);
    return output!;
  }
);
