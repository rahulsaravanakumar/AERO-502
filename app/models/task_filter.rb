# Shared filters are always applied after the requesting user's access scope.
class TaskFilter
     KEYS = %w[q project_id team_id subteam_id member_id task_from task_to].freeze
     attr_reader :query, :project_id, :team_id, :subteam_id, :member_id, :task_from, :task_to, :team_ids

     def initialize(values = {})
          values = values.to_h.stringify_keys
          @query = values["q"].to_s.strip
          %w[project_id team_id subteam_id member_id].each do |key|
               instance_variable_set("@#{key}", values[key].presence&.to_i)
          end
          @team_ids = Array(values["team_ids"]).reject(&:blank?).map(&:to_i).uniq
          @task_from = parse_date(values["task_from"])
          @task_to = parse_date(values["task_to"])
     end

     def to_h
          { "q" => query, "project_id" => project_id, "team_id" => team_id, "subteam_id" => subteam_id,
            "member_id" => member_id, "task_from" => task_from&.iso8601, "task_to" => task_to&.iso8601,
            "team_ids" => team_ids }.compact_blank
     end

     def active?
          to_h.any?
     end

     def selected_team_ids
          ([ team_id ] + team_ids).compact.uniq
     end

     def apply(tasks)
          tasks = tasks.joins(:project_subteam)
          tasks = tasks.where(project_subteams: { project_id: project_id }) if project_id
          if selected_team_ids.any?
               tasks = tasks.where(project_subteams: { project_id: Project.where(team_id: selected_team_ids).select(:id) })
          end
          tasks = tasks.where(project_subteams: { subteam_id: subteam_id }) if subteam_id
          tasks = tasks.where(id: TaskAssignment.where(user_id: member_id).select(:task_id)) if member_id
          tasks = tasks.where("tasks.due_date >= ?", task_from) if task_from
          tasks = tasks.where("tasks.start_date <= ?", task_to) if task_to
          return tasks if query.blank?

          pattern = "%#{Task.sanitize_sql_like(query)}%"
          tasks.where("tasks.title ILIKE :pattern OR tasks.description ILIKE :pattern", pattern: pattern)
     end

     private

     def parse_date(value)
          Date.iso8601(value.to_s)
     rescue Date::Error
          nil
     end
end
