-- Add recipientName column to messageQueue table
-- Migration: 20251114_add_recipientName_to_messageQueue

ALTER TABLE "messageQueue" 
ADD COLUMN IF NOT EXISTS "recipientName" TEXT;

-- Add comment
COMMENT ON COLUMN "messageQueue"."recipientName" IS 'Name of the message recipient (optional, for display purposes)';
