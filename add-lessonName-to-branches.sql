-- Add lessonName column to branches table
ALTER TABLE branches 
ADD COLUMN IF NOT EXISTS "lessonName" TEXT;

-- Update existing records with default values if needed
-- (optional - only if you want to set a default for existing branches)
UPDATE branches 
SET "lessonName" = "branchName" 
WHERE "lessonName" IS NULL;
