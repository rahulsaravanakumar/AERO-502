# Sprint 1 traceability and evidence

This matrix separates implemented repository evidence from external actions that still require the team/customer.

| Jira | Outcome | Repository evidence | Automated evidence | External evidence still required |
| --- | --- | --- | --- | --- |
| KAN-6 | Lead assigns one or more members | Task form and `TaskAssignment` uniqueness/team validation | Officer creation workflow test | UAT assignment screenshot |
| KAN-7 | Member-only task view | `Task.accessible_to`, My Tasks board, direct-URL guard | Scope and direct-access tests | UAT M3 results |
| KAN-8 | Estimated hours | Task estimate display/edit validation | Negative estimate persistence test | UAT A4 results |
| KAN-9 | Role-based sign-in/access | Session auth and server-side role checks | Login and cross-team authorization tests | Customer practice-account test |
| KAN-10 | Complete task cards | Task fields and create/edit form | Officer task creation test | UAT A2 results |
| KAN-11 | Project dashboard | Dashboard assignments/status/hours table | Member visibility workflow test | UAT A3 results |
| KAN-12 | Assigned member status | Member status form and authorization | Assigned status workflow test | UAT M1 results |
| KAN-13 | Record actual hours | `TimeEntry`, positive validation, member ownership | Positive/negative hours tests | UAT M2 results |
| KAN-14 | Organization-accessible hosting | Procfile and deployment guide | `/up` health route | Deploy in customer Heroku; record URL/owner/cost |
| KAN-15 | Admin/update/recovery instructions | `ADMIN_GUIDE.md` | CI and release procedure | Practice rollback teach-back |
| KAN-16 | Maintenance training | `TRAINING_GUIDE.md` | Checklist review | Conduct/record training |
| KAN-17 | User guide | `USER_GUIDE.md` | Workflow tests align with steps | Customer usability test |
| KAN-18 | User training | Member teach-back checklist | Checklist review | Conduct/record training |
| KAN-24 | Planned vs actual | Dashboard/task effort totals and variance | Total/variance model test | UAT comparison result |

A ticket should be claimed complete only after its deployed behavior, verification evidence, and customer/teaching-team decision are recorded. This repository does not claim that deployment, UAT acceptance, or training has already occurred.
