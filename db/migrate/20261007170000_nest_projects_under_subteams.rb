# Approved scope S01: each subteam belongs to one team and each project belongs
# to one subteam. Projects used to sit above teams; this moves existing data
# into the new structure without losing tasks or hours.
class NestProjectsUnderSubteams < ActiveRecord::Migration[8.1]
     class MigrationProject < ActiveRecord::Base
          self.table_name = "projects"
     end

     class MigrationSubteam < ActiveRecord::Base
          self.table_name = "subteams"
     end

     class MigrationTask < ActiveRecord::Base
          self.table_name = "tasks"
     end

     def up
          add_reference :projects, :subteam, foreign_key: true
          remove_index :projects, :name

          give_every_task_a_subteam
          move_projects_under_subteams
          MigrationProject.where(subteam_id: nil).delete_all

          change_column_null :projects, :subteam_id, false
          change_column_null :tasks, :subteam_id, false
          add_index :projects, %i[subteam_id name], unique: true
          remove_index :teams, %i[project_id name]
          remove_reference :teams, :project, foreign_key: true
          add_index :teams, :name, unique: true
     end

     def down
          raise ActiveRecord::IrreversibleMigration, "Restore the pre-update database backup to undo this change."
     end

     private

     # Tasks without a subteam move to a "General" subteam of their team.
     def give_every_task_a_subteam
          MigrationTask.where(subteam_id: nil).distinct.pluck(:team_id).each do |team_id|
               general = MigrationSubteam.find_or_create_by!(team_id: team_id, name: "General")
               MigrationTask.where(subteam_id: nil, team_id: team_id).update_all(subteam_id: general.id)
          end
     end

     # Each old project moves into the first subteam that used it and is copied
     # into any other subteam whose tasks used it.
     def move_projects_under_subteams
          MigrationTask.distinct.pluck(:project_id, :subteam_id).sort.each do |project_id, subteam_id|
               old_project = MigrationProject.find(project_id)
               if old_project.subteam_id.nil?
                    old_project.update_columns(subteam_id: subteam_id)
                    next
               end
               next if old_project.subteam_id == subteam_id

               copy = MigrationProject.find_or_create_by!(subteam_id: subteam_id, name: old_project.name) do |project|
                    project.archived_at = old_project.archived_at
               end
               MigrationTask.where(project_id: project_id, subteam_id: subteam_id).update_all(project_id: copy.id)
          end
     end
end
