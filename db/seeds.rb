# Practice data matching SAE AERO's structure: one project, three independent
# classes (teams) and their subteams. Subteam names are confirmed with the
# customer before production seeding.
project = Project.find_or_create_by!(name: "SAE AERO")

structure = {
     "Regular Class" => [ "Aerodynamics", "Structures" ],
     "Micro Class" => [ "Aerodynamics", "Structures" ],
     "Advanced Class" => [ "Aerodynamics", "Structures", "Autonomous Systems" ]
}
teams = structure.to_h do |team_name, subteam_names|
     team = Team.find_or_create_by!(project: project, name: team_name)
     subteam_names.each { |name| Subteam.find_or_create_by!(team: team, name: name) }
     [ team_name, team ]
end
regular = teams.fetch("Regular Class")
micro = teams.fetch("Micro Class")
regular_aero = regular.subteams.find_by!(name: "Aerodynamics")
regular_structures = regular.subteams.find_by!(name: "Structures")
micro_structures = micro.subteams.find_by!(name: "Structures")

password = ENV.fetch("DEMO_PASSWORD", "AeroSprint1!")

def seed_user(email, password, **attributes)
     user = User.find_or_initialize_by(email: email)
     user.update!(password: password, password_confirmation: password, **attributes)
     user
end

seed_user("chief@example.test", password, name: "Casey Chief", role: :chief_engineer, team: nil, subteam: nil)
officer_a = seed_user("officer.a@example.test", password, name: "Olivia Officer", role: :officer,
                      team: regular, subteam: regular_aero)
officer_b = seed_user("officer.b@example.test", password, name: "Owen Officer", role: :officer,
                      team: micro, subteam: micro_structures)
member_a = seed_user("member.a@example.test", password, name: "Morgan Member", role: :member,
                     team: regular, subteam: regular_aero)
member_b = seed_user("member.b@example.test", password, name: "Bailey Member", role: :member,
                     team: regular, subteam: regular_structures)
member_c = seed_user("member.c@example.test", password, name: "Cameron Member", role: :member,
                     team: micro, subteam: micro_structures)

wing_task = Task.find_or_initialize_by(project: project, title: "Wing load test")
wing_task.update!(
     team: regular,
     subteam: regular_aero,
     creator: officer_a,
     description: "Complete the load-test worksheet and attach a reviewed summary.",
     instructions: "Use the approved test fixture. Record each run and flag any result outside tolerance.",
     reference_links_text: "https://example.com/wing-load-test",
     start_date: Date.current - 3,
     due_date: 10.days.from_now.to_date,
     estimated_hours: 10,
     status: :in_progress
)
wing_task.assignee_ids = [ member_a.id, member_b.id ]

backlog_task = Task.find_or_initialize_by(project: project, title: "Review airfoil candidates")
backlog_task.update!(team: regular, subteam: regular_aero, creator: officer_a,
                     description: "Compare the three shortlisted airfoils.",
                     instructions: "Summarize lift, drag, and manufacturability tradeoffs.",
                     start_date: Date.current, due_date: 14.days.from_now.to_date,
                     estimated_hours: 6, status: :backlog)
backlog_task.assignee_ids = [ member_a.id ]

completed_task = Task.find_or_initialize_by(project: project, title: "Verify spar dimensions")
completed_task.update!(team: micro, subteam: micro_structures, creator: officer_b,
                       description: "Confirm the current spar dimensions against the drawing.",
                       instructions: "Record the drawing revision used.",
                       start_date: 9.days.ago.to_date, due_date: 2.days.ago.to_date,
                       estimated_hours: 4, status: :completed)
completed_task.assignee_ids = [ member_c.id ]

TimeEntry.find_or_create_by!(task: wing_task, user: member_a, hours: 2.5,
                             worked_on: Date.current - 2, note: "Fixture setup")
TimeEntry.find_or_create_by!(task: wing_task, user: member_a, hours: 1.5,
                             worked_on: Date.current - 1, note: "Test run")
TimeEntry.find_or_create_by!(task: wing_task, user: member_b, hours: 3,
                             worked_on: Date.current, note: "Results review")

puts "Seeded SAE AERO practice data. Demo password: #{password}"
