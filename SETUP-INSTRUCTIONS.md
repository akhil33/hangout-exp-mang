# ExpenseFlow Setup Instructions

## Changes Implemented

### 1. ✅ Logout Button Added
- **Location**: Sidebar (bottom section)
- **Color**: Red button to make it prominent
- **Function**: Signs out the current user and redirects to login page
- Users are automatically logged out and redirected when clicking the button

### 2. ✅ Role-Based Landing Page
- **Manager Users**: Can see Dashboard, Calendar, Analytics, and Setup views
- **Staff Users**: Can only see Dashboard and Calendar views
- Staff users are automatically redirected to Dashboard if they try to access Analytics or Setup

### 3. ✅ Role-Based Expense Button Visibility
- **"Add Expense" button only visible to Managers**
- Located in the Dashboard header
- Staff users won't see this button at all

### 4. ✅ Role Check Before Submission
- Added role verification in the `addExpense()` function
- If a staff user somehow triggers the modal, they'll get an alert: "Only managers can add expenses."
- The modal will close automatically if role check fails

### 5. ✅ Relaxed Database Policies
- Created SQL script: `supabase-fix-policies.sql`
- Run this script in your Supabase SQL Editor to fix all permission issues

## How to Fix Supabase Permissions

### Step 1: Open Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Click on "SQL Editor" in the left sidebar
3. Click "New query"

### Step 2: Run the Policy Fix Script
Copy and paste the contents of `supabase-fix-policies.sql` into the SQL Editor and run it.

**OR** run this quick fix:

```sql
-- Quick fix for expenses table
DROP POLICY IF EXISTS "Allow all for authenticated users" ON expenses;

ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all for authenticated users"
ON expenses
TO authenticated
USING (true)
WITH CHECK (true);

-- Quick fix for user_roles table
DROP POLICY IF EXISTS "Authenticated users can view all roles" ON user_roles;

ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view all roles"
ON user_roles FOR SELECT
TO authenticated
USING (true);
```

### Step 3: Verify It Works
1. Log in to your app
2. Click "Add Expense" (as a manager)
3. Fill in the form and submit
4. The expense should now be created successfully!

## User Flow

### For Managers:
1. Login → Dashboard (default view)
2. Can navigate to: Dashboard, Calendar, Analytics, Setup
3. Can click "Add Expense" button
4. Can create, view, and approve expenses
5. Can logout using the red "Logout" button

### For Staff:
1. Login → Dashboard (default view)
2. Can navigate to: Dashboard, Calendar only
3. Cannot see "Add Expense" button
4. Can only view expenses (no creation/approval)
5. Can logout using the red "Logout" button

## Testing Checklist

- [ ] Login as Manager
- [ ] Verify "Add Expense" button is visible
- [ ] Click "Add Expense" and submit form
- [ ] Verify expense is created in Supabase
- [ ] Click "Logout" button
- [ ] Login as Staff
- [ ] Verify "Add Expense" button is NOT visible
- [ ] Verify cannot access Analytics or Setup views
- [ ] Click "Logout" button

## Troubleshooting

### If you still get permission errors:
1. Check that you ran the SQL policy fix script
2. Verify in Supabase Table Editor → Policies that the "Allow all for authenticated users" policy exists
3. Check browser console for detailed error messages
4. Verify you're logged in (check the user badge in sidebar)

### If the Add Expense button doesn't appear:
1. Verify you're logged in as a Manager (check role badge in sidebar)
2. Click "Switch to Manager View" button in sidebar
3. Refresh the page

### If logout doesn't work:
1. Check browser console for errors
2. Verify Supabase is properly initialized
3. Try clearing browser cache and cookies

## Security Notes

⚠️ **Important**: The current policy setup is very permissive and meant for development/testing. For production:

1. Restrict INSERT operations to managers only
2. Restrict UPDATE operations based on expense ownership
3. Add proper role checks in database policies
4. Consider adding audit logs for expense operations

See the comments in `supabase-fix-policies.sql` for production-ready policy examples.
