-- Create the AI suggestions cache table
CREATE TABLE IF NOT EXISTS public.ai_suggestions (
  user_id      UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  suggestions  JSONB NOT NULL DEFAULT '[]',
  generated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.ai_suggestions ENABLE ROW LEVEL SECURITY;

-- Users can only read and write their own suggestions
CREATE POLICY "own_suggestions" ON public.ai_suggestions
  FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Storage policies for import-files bucket
-- Note: The bucket itself should be created via dashboard or CLI if possible,
-- but the policies can be defined here if the bucket exists.
-- Since the bucket might not exist yet, we'll try to create it in the next step.
