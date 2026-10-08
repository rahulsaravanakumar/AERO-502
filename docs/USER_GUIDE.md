# AERO Task Hub user guide

This guide covers the Sprint 2 release. Open it any time from **Help** in the page header or from the sign-in page. Every step is written out in words; nothing depends on a screenshot or on color. Every link, field and button can be reached with Tab and used with Enter or Space.

Never put real passwords or private member records in screenshots, notes or training material.

## Sign in

1. Open the website address your team supplied.
2. Select **Sign in with Google** and choose the Google (TAMU) account whose email the Chief Engineer added for you.
3. If your team is still using practice accounts, enter the practice email and password under **or use a practice account** and select **Sign in**.
4. Select **Sign out** in the header when you finish.

If you see "Access not authorized", see [Messages and what to do](#messages-and-what-to-do).

## Find your work

1. Select **Tasks** to open the task board. It has three columns: Backlog, In progress and Completed.
2. Select **My Tasks** to see only the tasks assigned to you.
3. Select a task title to open its details: deliverables, work instructions, reference links, start and due dates, estimated hours and assigned members.

Members see the tasks assigned to them. Officers see their own team's tasks; the Chief Engineer sees every team.

## Search and filter tasks

1. On the board, My Tasks or the Timeline, type a word in **Search tasks** to match task titles and descriptions.
2. Choose a **Project**, a **Team** and, if needed, a **Subteam**. Projects are listed as "Team · Subteam · Project". Subteams are listed with their team, for example "Regular Class · Aerodynamics".
3. Select **Apply**. Only tasks matching the search and both filters are shown.
4. Select **Clear** to show every task you are allowed to see again.

Your filters stay applied when you move between the board, My Tasks and the Timeline. A member's board first opens on their own team and subteam.

## Update task status

1. Open a task assigned to you.
2. Under **Update status**, choose Backlog, In progress or Completed.
3. Select **Save status**. The task moves to that column and stays there after you refresh.

## Record actual hours

1. Open a task assigned to you.
2. Under **Record actual hours**, enter the hours as a number greater than 0, such as `1` or `2.5`.
3. Choose the **Date worked** and, if you like, add a short note.
4. Select **Add hours**. The message "Hours were recorded." appears and the entry is listed under **Time entries**.

You can record at most 24 hours for one date across all your tasks.

## Correct or delete your hours

1. Open the task and find your entry under **Time entries**.
2. To correct it, select **Edit**, change the hours or date, and select **Save hours**.
3. To remove it, select **Delete**. The task's actual total updates straight away.

You can change only entries you recorded yourself.

## For officers and the Chief Engineer

### Create or edit a task

1. Select **New Task**.
2. Enter a **Title**, then choose the **Project**. Projects are listed as "Team · Subteam · Project"; the task's team and subteam come from its project. Officers see only their own team's projects.
3. Enter the **Start date** (today by default), **Due date** and **Estimated hours** (0 or more). Deliverables, work instructions and reference links (one full web address per line) are optional.
4. Tick the members to assign and select **Create Task**. New tasks start in Backlog.
5. To change a task later, open it and select **Edit task**.

### Task history

Open a task you manage and read **History**. Each line gives the date and time, who acted, and what happened in words, for example "Olivia Officer removed Bailey Member" or "changed the status from Backlog to In progress". The newest entry is first, and history cannot be edited or deleted.

### Board summary and hours (the project dashboard)

The task board doubles as the leader dashboard described in the acceptance tests.

1. Select **Tasks**. Each column heading shows how many tasks are in it, and any unfinished task past its due date shows a red **Overdue** label.
2. Choose a **Project**, team, subteam or search, and select **Apply**. The line above the board shows how many tasks are overdue and the actual hours against the estimate for the tasks shown.
3. Scroll to **Hours by member** below the board (or select its link above the board). Set **Hours from** and **Hours to** (both dates are included) and select **Show hours**. Each member's actual hours are shown against their assigned-task estimate as a chart and as a table with the difference.

### Timeline

1. Select **Timeline**. Each task is a bar from its start date to its due date, grouped by team and subteam. Gray is Backlog, blue is In progress, green is Completed, and red stripes mean overdue. The red vertical line is today.
2. Choose how many weeks to **Show** and use the search, team and subteam filters, then select **Apply**.
3. Use **‹ Previous**, **This week** and **Next ›** to move through time. A task outside the shown weeks says "Earlier" or "Later" on its row.
4. **Dates as a list** below the chart gives the same start and due dates in text.

### Teams, subteams and projects

1. Select **Teams**. Each class (team) lists its subteams, and each subteam lists its projects.
2. Use **Add subteam** or **Add project** to create one, **Rename** to change a name, and **Archive** to remove it from everyday lists.
3. Archived groups appear under **Archived**. Select one to see its tasks and hours, or select **Restore** to bring it back.

The Chief Engineer manages every team. Officers manage subteams and projects in their own team only.

### People (Chief Engineer)

1. Select **People**.
2. Select **Add person**, enter the name and Google email, and choose the role, team and subteam. The person can sign in with Google straight away.
3. Select **Change role** to change someone's role, team or subteam. The change applies the next time they load a page.
4. Select **Remove access** to stop someone signing in; their tasks and hours are kept. **Restore access** lets them sign in again.

## Messages and what to do

| Message | What it means | What to do |
| --- | --- | --- |
| Access not authorized. Email or password is incorrect, or the account has not been approved yet. | The practice email or password is wrong, or the account is not on the approved list. | Check the email and password and try again. If it still fails, ask the Chief Engineer to add you under People. |
| Access not authorized. Ask the Chief Engineer to add your email to the allowed people list. | Your Google email is not on the approved list. | Sign in with the Google account the Chief Engineer added, or ask them to add this email. |
| Access not authorized. Your access has been removed. | The Chief Engineer removed your access. | Ask the Chief Engineer to restore your access. |
| Google sign-in was cancelled or failed. Please try again. | The Google window was closed or Google refused the request. | Select Sign in with Google again and finish choosing your account. |
| Please sign in to view that page. | You are signed out. | Sign in, then open the page again. |
| Title can't be blank (or another field "can't be blank") | A required field is empty. | Fill in the field named next to the message and save again. |
| Estimated hours is not a number / Hours is not a number | Letters or symbols were typed where a number is needed. | Type digits only, for example `1` or `2.5`, and save again. |
| Hours must be greater than 0 | Zero or a negative number was entered. | Enter a number above 0. |
| Hours for (date) would total (number); a member can record at most 24 hours per day | Your hours for that date across all tasks would pass 24. | Check your other entries for that date, then enter fewer hours or a different date. |
| Due date must be on or after the start date | The due date is earlier than the start date. | Choose a due date on or after the start date. |
| End date must be on or after the start date | Under Hours by member, Hours to is earlier than Hours from. | Choose a later Hours to date, or select Clear. |
| Start date is not a valid date / End date is not a valid date | Hours by member could not read a date. | Pick the date with the date picker or type it as YYYY-MM-DD. |
| Reference links must each be a full web address starting with http:// or https:// | A reference link is incomplete. | Put one full address per line, for example `https://example.com/plan`. |
| You can update only tasks assigned to you. | You tried to change a task that is not yours. | Ask an officer to assign you, or update one of your own tasks. |
| You cannot view that task. | The task belongs to work you are not allowed to see. | Return to Tasks or My Tasks. |
| You can change only your own hours. | You tried to edit or delete someone else's entry. | Ask that member to correct their own entry. |
| You can manage only tasks on your own team. | An officer tried to change another team's task. | Ask that team's officer or the Chief Engineer. |
| Project must belong to your team | An officer chose another team's project. | Choose one of your team's projects. |
| The timeline is available to team officers and the Chief Engineer. | Members cannot open the timeline. | Use Tasks and My Tasks to see your dates. |
| You can manage only your own team's subteams and projects. | An officer tried to change another team's group. | Ask the Chief Engineer. |
| Only the Chief Engineer can manage people and roles. | Only the Chief Engineer can open People. | Ask the Chief Engineer to make the change. |
