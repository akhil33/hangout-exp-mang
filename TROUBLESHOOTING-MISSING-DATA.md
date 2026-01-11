# Troubleshooting: Missing Expenses in UI

## Problem
- Database shows 5 expenses
- App/Calendar only shows 4 expenses
- Some newly created expenses don't appear

## Root Cause
**Row Level Security (RLS) policies** are filtering expenses based on `user_id`, but some expenses have:
- NULL `user_id` (created before user_id column was added)
- Different `user_id` (created by a different user or session)

## Quick Diagnostic Steps

### Step 1: Check Browser Console
Open the app and check the console for these messages:

```
✅ Successfully fetched 4 expenses from database
📊 Total count from database: 5
⚠️ WARNING: Count mismatch! Expected 5 but got 4
⚠️ This might indicate RLS policy filtering some rows
```

If you see the warning, RLS is filtering rows.

### Step 2: Check Database
In Supabase SQL Editor, run:
```sql
SELECT id, name, user_id, due_date
FROM expenses
ORDER BY id;
```

Look for:
- Expenses with NULL `user_id`
- Expenses with different `user_id` values

### Step 3: Check Your User ID
```sql
SELECT id, email FROM auth.users;
```

Compare this to the `user_id` in your expenses.

## Solutions

### Solution 1: Disable RLS (Quickest - Development Only)
**Best for:** Single-user testing, development

Run in Supabase SQL Editor:
```sql
ALTER TABLE expenses DISABLE ROW LEVEL SECURITY;
```

✅ All expenses will be immediately visible
⚠️ Not suitable for production

### Solution 2: Update RLS Policies (Recommended)
**Best for:** Multi-user apps in development

Run the entire `FIX-MISSING-EXPENSES.sql` script which:
1. Drops old policies
2. Creates new permissive policies that allow all authenticated users to see all expenses

✅ Keeps RLS enabled
✅ All users can see all expenses
✅ Good for team collaboration

### Solution 3: Fix user_id Values
**Best for:** Production apps with user-specific data

1. Get your user ID:
```sql
SELECT id FROM auth.users WHERE email = 'your@email.com';
```

2. Update expenses:
```sql
UPDATE expenses
SET user_id = 'your-user-id-here'
WHERE user_id IS NULL;
```

✅ Maintains data integrity
✅ Expenses are properly associated with users

## After Applying Solution

### Verification Steps:

1. **Refresh the app** (Hard refresh: Cmd+Shift+R or Ctrl+Shift+F5)

2. **Check console logs** for:
```
✅ Successfully fetched 5 expenses from database
📊 Total count from database: 5
```
(No warning = all good!)

3. **Verify in UI**:
   - Dashboard should show all expenses
   - Calendar should have all dates highlighted
   - Counts should match database

## Understanding the Issue

### What is Row Level Security (RLS)?
RLS is a database security feature that filters rows based on the current user. It's like having a WHERE clause automatically added to every query.

### Why does this happen?
```sql
-- Example of a restrictive policy:
CREATE POLICY "user_expenses_only"
ON expenses FOR SELECT
USING (user_id = auth.uid());  -- Only show MY expenses
```

This policy means:
- User A can only see expenses where `user_id = A`
- User B can only see expenses where `user_id = B`
- Nobody can see expenses with NULL `user_id`

### Our permissive policy:
```sql
CREATE POLICY "expenses_select_all"
ON expenses FOR SELECT
USING (true);  -- Show ALL expenses to authenticated users
```

This means:
- All authenticated users see all expenses
- Perfect for a restaurant management app where managers need to see everything

## Future Considerations

For a production multi-user app, you might want:

```sql
-- Managers see everything, staff see only their own
CREATE POLICY "expenses_by_role"
ON expenses FOR SELECT
USING (
    -- Manager: see all
    EXISTS (
        SELECT 1 FROM user_roles
        WHERE user_id = auth.uid()
        AND role = 'manager'
    )
    OR
    -- Staff: see only their own
    user_id = auth.uid()
);
```

## Common Mistakes

❌ **Don't do this:**
```sql
-- This filters out NULL user_id
USING (user_id = auth.uid())
```

✅ **Do this instead:**
```sql
-- This shows everything
USING (true)
```

Or for conditional access:
```sql
-- This handles NULL and checks role
USING (
    user_id = auth.uid()
    OR user_id IS NULL
    OR EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'manager')
)
```

## Still Having Issues?

1. **Check Supabase Realtime**: Ensure it's enabled for the expenses table
2. **Clear cache**: Try incognito/private browsing mode
3. **Check network**: Look for failed requests in Network tab
4. **Verify SQL ran successfully**: Check for errors in Supabase SQL Editor
