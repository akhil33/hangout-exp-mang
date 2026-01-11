-- DIAGNOSTIC SCRIPT TO FIND WHY EXPENSES AREN'T SHOWING
-- Run this in Supabase SQL Editor to diagnose the issue

-- =============================================
-- STEP 1: Check if expenses table exists and has data
-- =============================================
SELECT 'Total expenses in table:' as check_type, COUNT(*) as count
FROM expenses;

-- =============================================
-- STEP 2: Show all expenses (bypass RLS temporarily)
-- =============================================
SELECT 'All expenses (with RLS bypassed):' as info;
SELECT id, name, amount, due_date, category, frequency, status, user_id
FROM expenses
ORDER BY due_date DESC;

-- =============================================
-- STEP 3: Check RLS status on expenses table
-- =============================================
SELECT 'RLS Status:' as info,
       schemaname,
       tablename,
       rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'expenses';

-- =============================================
-- STEP 4: Check all policies on expenses table
-- =============================================
SELECT 'Policies on expenses table:' as info;
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual::text as using_expression,
    with_check::text as with_check_expression
FROM pg_policies
WHERE tablename = 'expenses';

-- =============================================
-- STEP 5: Check user_roles table
-- =============================================
SELECT 'User roles:' as info;
SELECT * FROM user_roles;

-- =============================================
-- STEP 6: Check if current user can see expenses
-- =============================================
-- This query runs as the authenticated user
-- It will show what the app sees
SELECT 'Expenses visible to current user:' as info;
SELECT id, name, amount, due_date, category, status
FROM expenses
ORDER BY due_date DESC;

-- =============================================
-- RECOMMENDED FIX
-- =============================================
-- If Step 6 returns 0 rows but Step 2 shows data,
-- it means RLS is blocking access.
--
-- Run this to fix:
--
-- DROP POLICY IF EXISTS "Allow all for authenticated users" ON expenses;
--
-- ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
--
-- CREATE POLICY "Allow read for all authenticated"
-- ON expenses FOR SELECT
-- TO authenticated
-- USING (true);
--
-- CREATE POLICY "Allow all operations for authenticated"
-- ON expenses
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);
