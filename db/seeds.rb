project = Project.find_or_create_by!(name: "SAE AERO Design")
team_a = Team.find_or_create_by!(project: project, name: "Aerodynamics")
team_b = Team.find_or_create_by!(project: project, name: "Structures")
Subteam.find_or_create_by!(team: team_a, name: "Wing Analysis")
Subteam.find_or_create_by!(team: team_b, name: "Airframe")

password = ENV.fetch("DEMO_PASSWORD", "AeroSprint1!")

chief = User.find_or_initialize_by(email: "chief@example.test")
chief.update!(name: "Casey Chief", role: :chief_engineer, team: nil,
              password: password, password_confirmation: password)

officer_a = User.find_or_initialize_by(email: "officer.a@example.test")
officer_a.update!(name: "Olivia Officer", role: :officer, team: team_a,
                  password: password, password_confirmation: password)

officer_b = User.find_or_initialize_by(email: "officer.b@example.test")
officer_b.update!(name: "Owen Officer", role: :officer, team: team_b,
                  password: password, password_confirmation: password)

member_a = User.find_or_initialize_by(email: "member.a@example.test")
member_a.update!(name: "Morgan Member", role: :member, team: team_a,
                 password: password, password_confirmation: password)

member_b = User.find_or_initialize_by(email: "member.b@example.test")
member_b.update!(name: "Bailey Member", role: :member, team: team_a,
                 password: password, password_confirmation: password)

member_c = User.find_or_initialize_by(email: "member.c@example.test")
member_c.update!(name: "Cameron Member", role: :member, team: team_b,
                 password: password, password_confirmation: password)

wing_task = Task.find_or_initialize_by(project: project, title: "Wing load test")
wing_task.update!(
     team: team_a,
     subteam: team_a.subteams.first,
     creator: officer_a,
     description: "Complete the load-test worksheet and attach a reviewed summary.",
     instructions: "Use the approved test fixture. Record each run and flag any result outside tolerance.",
     link_url: "https://example.com/wing-load-test",
     due_date: 10.days.from_now.to_date,
     estimated_hours: 10,
     status: :in_progress
)
wing_task.assignee_ids = [ member_a.id, member_b.id ]

backlog_task = Task.find_or_initialize_by(project: project, title: "Review airfoil candidates")
backlog_task.update!(team: team_a, creator: officer_a,
                     description: "Compare the three shortlisted airfoils.",
                     instructions: "Summarize lift, drag, and manufacturability tradeoffs.",
                     due_date: 14.days.from_now.to_date, estimated_hours: 6, status: :backlog)
backlog_task.assignee_ids = [ member_a.id ]

completed_task = Task.find_or_initialize_by(project: project, title: "Verify spar dimensions")
completed_task.update!(team: team_b, creator: officer_b,
                       description: "Confirm the current spar dimensions against the drawing.",
                       instructions: "Record the drawing revision used.",
                       due_date: 2.days.ago.to_date, estimated_hours: 4, status: :completed)
completed_task.assignee_ids = [ member_c.id ]

TimeEntry.find_or_create_by!(task: wing_task, user: member_a, hours: 2.5,
                             worked_on: Date.current - 2, note: "Fixture setup")
TimeEntry.find_or_create_by!(task: wing_task, user: member_a, hours: 1.5,
                             worked_on: Date.current - 1, note: "Test run")
TimeEntry.find_or_create_by!(task: wing_task, user: member_b, hours: 3,
                             worked_on: Date.current, note: "Results review")

puts "Seeded Sprint 1 practice data. Demo password: #{password}"
