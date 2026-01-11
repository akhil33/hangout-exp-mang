-- Check current RLS policies on expenses table

-- 1. Check if RLS is enabled
SELECT
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'expenses';

-- 2. List all policies
SELECT
    policyname,
    cmd as operation,
    roles,
    qual::text as using_clause,
    with_check::text as with_check_clause
FROM pg_policies
WHERE tablename = 'expenses'
ORDER BY cmd, policyname;

-- 3. Check user_id in all expenses
SELECT
    id,
    name,
    user_id,
    CASE
        WHEN user_id IS NULL THEN '⚠️ NULL user_id (will be filtered)'
        WHEN user_id = auth.uid() THEN '✓ Your expense'
        ELSE '❌ Different user (will be filtered)'
    END as access_status
FROM expenses
ORDER BY id;

-- 4. Check your current user ID
SELECT
    'Your current user ID:' as info,
    auth.uid() as user_id;

-- =============================================
-- ANALYSIS
-- =============================================
-- If you see expenses with different user_id or NULL user_id,
-- and the policy has a WHERE clause like "user_id = auth.uid()",
-- those expenses will be filtered out.
--
-- Solution: Disable RLS or update the policy to allow all users
