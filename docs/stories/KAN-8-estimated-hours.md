# KAN-8: View estimated task hours

## Associated user story

[Jira KAN-8](https://tamu-team-b3obo8no.atlassian.net/browse/KAN-8)

As a team member, I want to see the estimated number of hours for each assigned task so that I can understand and manage my workload.

## Acceptance criteria

1. Given an assigned task with an estimate of 10 hours, when the member opens the task, the estimate is shown as 10 hours with a clear "Estimated hours" label.
2. Given an authorized Team Lead, when they enter or update a non-negative numeric estimate (including decimals) and save, the value persists after reopening or refreshing the task.
3. Given a saved estimate, when the assigned member views the task, the member sees the latest saved value and cannot change it without Team Lead authorization.
4. Given a negative or nonnumeric estimate, when the Team Lead tries to save, a clear validation error is shown and the previous valid value remains unchanged.
5. Given a task with no estimate, when the member views it, "Not estimated" is shown; a saved value of 0 is shown as 0 hours.

## Traceability

Scope S-03 / US-3 in Requirements Traceability Clinic, p. 6, covers estimated hours. UAT form (Sprint 1, A2.3): enter 10 estimated hours, save and reopen; the estimate remains 10 hours. Criteria 3-5 add proposed permission and edge-case checks. No UAT execution or customer approval is claimed.

## Definition of Done (proposed for this lab)

The supplied AERO502_Sprint1_Partial_Notebook_v1.docx has no completed Definition of Done in its Appendix. This proposed checklist follows its Section 2.3 quality-strategy categories and evidence traceability; it is pending team agreement.

- [ ] All KAN-8 acceptance criteria are implemented and verified.
- [ ] Automated tests cover normal estimates, decimals, zero, missing values, invalid input, persistence, and authorization.
- [ ] CI tests and configured quality checks pass.
- [ ] A teammate reviews the PR and requested changes are resolved before merge.
- [ ] Server-side authorization and input validation prevent unauthorized or invalid estimate changes.
- [ ] Estimated-hours labels and validation messages are clear, readable, and keyboard accessible.
- [ ] The feature is verified on the review/staging app, with evidence linked to Jira and the PR.
- [ ] Relevant documentation, known defects, and customer acceptance or feedback decisions are recorded in the notebook/Jira.

## Lab status

Documentation only. Implementation, tests, CI, deployment validation, and review are pending. This draft PR does not claim the story is done.
