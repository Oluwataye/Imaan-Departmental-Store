# Complete Setup Guide - Supabase & Netlify

## Part 1: Supabase Database Setup

### Step 1: Access Your Supabase Project

1. Go to your Supabase project: https://supabase.com/dashboard/project/fxtsjzpcfilewhirvbbe
2. Wait for the project to finish initializing (if it's still setting up)

### Step 2: Run the Database Schema

1. In your Supabase dashboard, click on **SQL Editor** in the left sidebar
2. Click **"New query"**
3. Open the file: `database/schema.sql` (I just created it in your project)
4. Copy ALL the SQL code from that file
5. Paste it into the Supabase SQL Editor
6. Click **"Run"** or press `Ctrl+Enter`
7. Wait for it to complete (you should see "Success. No rows returned")

### Step 3: Get Your Supabase Credentials

1. In Supabase, click **Settings** (gear icon) → **API**
2. Copy these two values:
   - **Project URL** (example: `https://fxtsjzpcfilewhirvbbe.supabase.co`)
   - **anon public key** (long string starting with `eyJ...`)
3. **Keep these safe** - you'll need them for Netlify!

### Step 4: Create Your First Admin User

1. In Supabase, go to **Authentication** → **Users**
2. Click **"Add user"** → **"Create new user"**
3. Fill in:
   - Email: your email address
   - Password: create a strong password
   - Auto Confirm User: ✅ Check this box
4. Click **"Create user"**
5. Copy the User ID (UUID) that appears

### Step 5: Set the User as Admin

1. Go to **Table Editor** → Select **users** table
2. Click **"Insert"** → **"Insert row"**
3. Fill in:
   - `id`: Paste the User ID you copied
   - `email`: Same email as above
   - `username`: Choose a username (e.g., "admin")
   - `name`: Your full name
   - `role`: Select **ADMIN**
4. Click **"Save"**

---

## Part 2: Netlify Deployment

### Step 1: Start Netlify Deployment

1. Go to: https://app.netlify.com/start/repos/Oluwataye%2FImaan-Departmental-Store
2. Click **"Connect to GitHub"** (if not already connected)
3. Authorize Netlify to access your repositories
4. Select the repository: **Imaan-Departmental-Store**

### Step 2: Configure Build Settings

The settings should auto-detect from `netlify.toml`, but verify:

- **Build command**: `npm run build`
- **Publish directory**: `dist`
- **Branch to deploy**: `main`

### Step 3: Add Environment Variables

Click **"Show advanced"** or **"Add environment variables"**

Add these TWO variables:

**Variable 1:**
- Key: `VITE_SUPABASE_URL`
- Value: [Paste your Supabase Project URL from Step 3 above]

**Variable 2:**
- Key: `VITE_SUPABASE_ANON_KEY`
- Value: [Paste your Supabase anon public key from Step 3 above]

### Step 4: Deploy!

1. Click **"Deploy site"** or **"Save & Deploy"**
2. Wait 2-5 minutes for the build to complete
3. You'll see a URL like: `https://random-name-12345.netlify.app`

### Step 5: Configure Supabase for Netlify

1. Go back to Supabase: **Authentication** → **URL Configuration**
2. Add your Netlify URL to:
   - **Site URL**: `https://your-site-name.netlify.app`
   - **Redirect URLs**: `https://your-site-name.netlify.app/**`
3. Click **"Save"**

---

## Part 3: Test Your Deployment

1. Visit your Netlify URL
2. You should see the login page
3. Log in with the admin credentials you created
4. You should be redirected to the Admin Dashboard

---

## Quick Reference

### Supabase Credentials Location
- Dashboard → Settings → API
- Copy: Project URL and anon public key

### Netlify Environment Variables
```
VITE_SUPABASE_URL=https://fxtsjzpcfilewhirvbbe.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ... (your actual key)
```

### Admin Login
- Email: [the email you created]
- Password: [the password you set]

---

## Troubleshooting

### Build Fails on Netlify
- Check that environment variables are set correctly
- Look at the build logs for specific errors
- Ensure both variables are present

### Can't Log In
- Verify the user exists in Supabase Authentication
- Check that the user has a row in the `users` table with role='ADMIN'
- Verify Supabase URL in Netlify matches your project URL

### Blank Page After Login
- Check browser console for errors
- Verify environment variables are correct
- Check Supabase redirect URLs include your Netlify domain

---

## Next Steps After Successful Deployment

1. ✅ Customize your site name in Netlify (Site settings → Change site name)
2. ✅ Update store settings (Settings page in the app)
3. ✅ Add more users (Users page)
4. ✅ Add products to inventory
5. ✅ Test the POS system

**Your store is ready to use!** 🎉
