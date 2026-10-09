# Search text plus project, team and subteam filters, shared by the board,
# My Tasks and the timeline. Always applied on top of the user's permitted tasks.
class TaskFilter
     KEYS = %w[q project_id team_id subteam_id].freeze

     attr_reader :query, :project_id, :team_id, :subteam_id

     def initialize(values = {})
          values = values.to_h.stringify_keys
          @query = values["q"].to_s.strip
          @project_id = values["project_id"].presence&.to_i
          @team_id = values["team_id"].presence&.to_i
          @subteam_id = values["subteam_id"].presence&.to_i
     end

     def to_h
          { "q" => query, "project_id" => project_id, "team_id" => team_id, "subteam_id" => subteam_id }.compact_blank
     end

     def active?
          to_h.any?
     end

     def apply(tasks)
          tasks = tasks.where(project_id: project_id) if project_id
          tasks = tasks.where(team_id: team_id) if team_id
          tasks = tasks.where(subteam_id: subteam_id) if subteam_id
          return tasks if query.blank?

          pattern = "%#{Task.sanitize_sql_like(query)}%"
          tasks.where("tasks.title ILIKE :pattern OR tasks.description ILIKE :pattern", pattern: pattern)
     end
end
