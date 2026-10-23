# One source for on-screen summaries and all CSV downloads.
class TaskReport
     attr_reader :tasks, :hours

     def initialize(user:, filter:, from: nil, to: nil, tasks: nil)
          @tasks = (tasks || filter.apply(Task.accessible_to(user))).includes(:project, :team, :subteam, :assignees, time_entries: :user).order(:title, :id).to_a
          cohort = User.member.where(access_revoked_at: nil)
          cohort = cohort.in_teams(user.team_id) unless user.chief_engineer?
          cohort = cohort.in_teams(filter.selected_team_ids) if filter.selected_team_ids.any?
          cohort = cohort.in_teams(Project.where(id: filter.project_id).select(:team_id)) if filter.project_id
          cohort = cohort.in_subteam(filter.subteam_id) if filter.subteam_id
          @hours = HourSummary.new(tasks: @tasks, from: from, to: to, members: cohort, member_id: filter.member_id)
     end
end
