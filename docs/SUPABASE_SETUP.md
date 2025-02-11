# [Supabase](https://supabase.com/dashboard/projects) setup for Nesters

Nesters requires the following functionalities to work properly with Supabase

- Authentication
- Database
- Storage

## Initial setup

- Create a new project in Supabase and set your DB region to the one closest to you.

- Copy the secrets from the project settings and paste them in the `.env` file in the root of the project.

## Authentication 

- Navigate to authentication tab and select the **Sign In/ Up** tab.

- Add [Google](https://supabase.com/docs/guides/auth/social-login/auth-google?queryGroups=platform&platform=flutter) and [Apple](https://supabase.com/docs/guides/auth/social-login/auth-apple#:~:text=To%20support%20Sign%20in%20with,Supabase%20dashboard%20for%20your%20project.&text=Using%20an%20OAuth%20flow%20initiated,browser%2C%20usually%20suitable%20for%20websites.) Sign in methods in the Auth Provider.

- Make sure to add the correct client ID and secret in the settings.



## Database

- Navigate to the SQL tab and run the following SQL commands to create the required tables.

- Make sure to create a `prod` using the following commands and navigate to Project Settings > Data API and add the prod schema to Exposed schemas and extra search paths.

- Copy the SQL commands from the [`dev_table_script`](../scripts/supabase_sql_dev_queries.sql), [`prod_table_script`](../scripts/supabase_sql_prod_queries.sql) files and paste them in the SQL editor.

- Add the required RLS policies to the tables.

- Populate the tables with the required data mainly the **universities**, **marketplace_categories**, **indian_states** and **indian_languages** tables.

## Storage

- Navigate to the Storage tab and create the following buckets.
    - profile_images
    - sublets
    - marketplaces
    - apartments

- Make sure to mark the bucket as public and restrict file-size upload limit.

- Additionally, add the required policies to the buckets.

