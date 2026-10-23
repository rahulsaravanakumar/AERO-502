require "csv"

class ReportCsv
     TASK_HEADERS = [ "Task", "Project", "Team", "Subteam", "Assignees", "Status", "Start date", "Due date", "Estimated hours", "Actual hours" ].freeze
     MEMBER_HEADERS = [ "Member", "Class", "Team", "Subteam", "Project", "Total actual hours" ].freeze

     def self.tasks(report)
          generate(TASK_HEADERS, report.tasks.map do |task|
               [ task.title, task.project.name, task.team.name, task.subteam.name,
                 task.assignees.sort_by(&:name).map(&:name).join("; "), task.status.humanize,
                 task.start_date.iso8601, task.due_date.iso8601, task.estimated_hours.to_d.to_s("F"), report.hours.actual_for_task(task).to_s("F") ]
          end)
     end

     def self.members(report, project_name: "All selected projects")
          generate(MEMBER_HEADERS, report.hours.member_rows.map do |row|
               work = report.tasks.select { |task| task.assignees.include?(row.member) || task.time_entries.any? { |entry| entry.user_id == row.member.id } }
               teams = work.empty? ? Array(row.member.team) : work.map(&:team)
               subteams = work.empty? ? Array(row.member.subteam) : work.map(&:subteam)
               team_names = teams.map(&:name).uniq.sort.join("; ")
               [ row.member.name, team_names, team_names, subteams.map(&:name).uniq.sort.join("; "),
                 project_name, row.actual.to_s("F") ]
          end)
     end

     def self.projects(report)
          generate([ "Project", "Class", "Team", "Subteam", "Total actual hours" ], report.tasks.group_by(&:project).map do |project, tasks|
               [ project.name, project.team.name, project.team.name, tasks.map { |task| task.subteam.name }.uniq.sort.join("; "),
                 tasks.sum { |task| report.hours.actual_for_task(task) }.to_d.to_s("F") ]
          end)
     end

     # RFC-compatible quoting preserves commas, quotes and newlines. An apostrophe
     # prevents spreadsheet programs from evaluating user-supplied text as a formula.
     def self.generate(headers, rows)
          "\uFEFF" + CSV.generate(row_sep: "\r\n", force_quotes: true) do |csv|
               csv << headers
               rows.each do |row|
                    csv << row.map { |value| value.to_s.match?(/\A[\s\u0000-\u001f]*[=+@-]/) ? "'#{value}" : value }
               end
          end
     end
end
