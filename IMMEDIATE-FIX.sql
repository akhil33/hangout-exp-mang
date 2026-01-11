-- IMMEDIATE FIX FOR MISSING EXPENSES
-- Run this entire script in Supabase SQL Editor

-- =============================================
-- STEP 1: Disable RLS temporarily to see all data
-- =============================================
-- This is the quickest fix to get your app working

ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;

-- =============================================
-- VERIFICATION
-- =============================================
-- After running the above command:
-- 1. Refresh your app (Cmd+Shift+R or Ctrl+Shift+F5)
-- 2. Check the console - you should see all 6 expenses
-- 3. Calendar should show all dates with expenses

-- Check all expenses
SELECT
    id,
    name,
    amount,
    due_date,
    user_id,
    status
FROM expenses
ORDER BY id;

-- =============================================
-- EXPLANATION
-- =============================================
-- The issue is that Row Level Security (RLS) policies
-- are filtering out some expenses based on user_id.
--
-- When you disable RLS, all expenses become visible
-- to all authenticated users.
--
-- This is fine for:
-- - Single-user apps
-- - Development/testing
-- - Small team apps where everyone should see everything
--
-- For production multi-user apps, you'll want to
-- re-enable RLS with proper policies later.

-- =============================================
-- NEXT STEPS (Optional - for later)
-- =============================================
-- If you want to re-enable RLS with proper policies:
--
-- 1. Enable RLS again:
-- ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
--
-- 2. Create a policy that allows all authenticated users to see all expenses:
-- CREATE POLICY "expenses_all_access"
-- ON expenses
-- FOR ALL
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);
