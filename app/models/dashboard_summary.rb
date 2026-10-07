# Figures for the leader dashboard: status counts, assignments, overdue work
# and each member's estimated vs. actual hours for an optional date range.
class DashboardSummary
     MemberRow = Struct.new(:member, :tasks, :estimate, :actual)

     attr_reader :project, :from, :to, :errors

     def initialize(user:, project:, filter: TaskFilter.new, from: nil, to: nil)
          @user = user
          @project = project
          @filter = filter
          @errors = []
          @from = parse_date(from, "Start date")
          @to = parse_date(to, "End date")
          return unless @from && @to && @to < @from

          @errors << "End date must be on or after the start date"
          @from = @to = nil
     end

     # Permitted, filtered tasks for the selected project, or all projects when none is chosen.
     def tasks
          @tasks ||= begin
               scope = @filter.apply(Task.accessible_to(@user))
               scope = scope.where(project: project) if project
               scope.includes(:team, :assignees, time_entries: :user).order(:due_date, :title).to_a
          end
     end

     def status_counts
          Task.statuses.keys.index_with { |status| tasks.count { |task| task.status == status } }
     end

     def overdue_tasks
          tasks.select { |task| !task.completed? && task.due_date < Date.current }
     end

     def member_rows
          @member_rows ||= members.map do |member|
               assigned = tasks.select { |task| task.assignees.include?(member) }
               MemberRow.new(member, assigned, assigned.sum(&:estimated_hours), actual_hours_for(member))
          end
     end

     # Each task estimate is counted once, however many members share it.
     def total_estimate
          tasks.sum(&:estimated_hours)
     end

     def total_actual
          entries_in_range.sum(&:hours)
     end

     def chart_scale
          [ *member_rows.map(&:estimate), *member_rows.map(&:actual), 1 ].max
     end

     private

     def members
          (tasks.flat_map(&:assignees) + entries_in_range.map(&:user)).uniq.sort_by(&:name)
     end

     def entries_in_range
          @entries_in_range ||= tasks.flat_map(&:time_entries).select do |entry|
               (from.nil? || entry.worked_on >= from) && (to.nil? || entry.worked_on <= to)
          end
     end

     def actual_hours_for(member)
          entries_in_range.select { |entry| entry.user_id == member.id }.sum(BigDecimal("0"), &:hours)
     end

     def parse_date(value, label)
          return if value.blank?

          Date.iso8601(value)
     rescue Date::Error
          @errors << "#{label} is not a valid date"
          nil
     end
end
