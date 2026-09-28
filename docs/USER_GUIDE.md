# AERO Task Hub user guide

This guide covers the Sprint 1 practice release. Never put real passwords or private member records in screenshots or training notes.

## Practice accounts

All seeded accounts use the password `AeroSprint1!` unless the deployer sets `DEMO_PASSWORD`.

| Role | Email |
| --- | --- |
| Chief Engineer | chief@example.test |
| Aerodynamics officer | officer.a@example.test |
| Structures officer | officer.b@example.test |
| Aerodynamics member A | member.a@example.test |
| Aerodynamics member B | member.b@example.test |
| Structures member | member.c@example.test |

## Sign in

1. Open the supplied application URL.
2. Enter your practice email and password.
3. Select **Sign in**. A wrong password leaves you signed out and explains that the email or password is incorrect.
4. Use **Sign out** in the header when finished.

Every field and action can be reached with Tab and activated with Enter or Space.

## Find assigned work

1. Select **My Tasks** in the header.
2. The board shows only tasks assigned to the signed-in account.
3. Select a task title to open its details.
4. Select **Tasks** to return to the complete board permitted for your role. A member's complete board still contains only that member's assignments.

If no tasks are assigned, the page says so rather than showing another team's data.

## Update task status

1. Open an assigned task.
2. Under **Update status**, choose Backlog, In progress, or Completed.
3. Select **Save status**.
4. Refresh the page to confirm the saved value remains.

You cannot update a task that is not assigned to you.

## Record actual hours

1. Open an assigned task.
2. Under **Record actual hours**, enter a positive number such as `1` or `2.5`.
3. Choose the date worked and optionally enter a short note.
4. Select **Add hours**.
5. Confirm the task's Actual total and your entry under Hours by member.

If letters, zero, or a negative value are entered, correct the value to a number greater than zero and submit again. Invalid entries do not change the existing total.

## Create or edit a task (Chief Engineer/officer)

1. Select **New Task**.
2. Enter a title, expected deliverables, work instructions, optional supporting link, due date, and a non-negative estimate.
3. Select the project and team. Officers are restricted to their own team even if a different team is submitted directly.
4. Select one or more members. A repeated member is stored only once.
5. Select **Create Task**.
6. Reopen the task to verify its information and assignments.

Supporting links must begin with `http://` or `https://`. Negative or nonnumeric estimates are rejected without replacing the last valid value.
