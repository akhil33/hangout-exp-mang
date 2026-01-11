-- IMMEDIATE FIX: Disable RLS to see all expenses
-- Run this single command in Supabase SQL Editor

ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;

-- Verification: Check that all expenses are visible
SELECT id, name, amount, due_date, user_id
FROM expenses
ORDER BY id;

-- After running this, refresh your app
-- You should see all 8 expenses (IDs: 1, 3, 4, 5, 6, 7, 8, 9)
