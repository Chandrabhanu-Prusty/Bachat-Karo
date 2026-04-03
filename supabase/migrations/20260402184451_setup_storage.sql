-- Create the import-files storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('import-files', 'import-files', false)
ON CONFLICT (id) DO NOTHING;

-- Users can upload files into their own folder
CREATE POLICY "import_files_user_upload"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'import-files' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- Users can download their own files
CREATE POLICY "import_files_user_download"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'import-files' AND
  (storage.foldername(name))[2] = auth.uid()::text
);

-- Users can delete their own files
CREATE POLICY "import_files_user_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'import-files' AND
  (storage.foldername(name))[2] = auth.uid()::text
);
