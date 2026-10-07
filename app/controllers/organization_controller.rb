class OrganizationController < ApplicationController
     before_action :require_sign_in
     before_action -> { deny_access unless current_user.leader? }

     def show
          if current_user.chief_engineer?
               @teams = Team.active
               @projects = Project.active
               @archived = Project.archived.to_a + Team.archived.to_a + Subteam.archived.to_a
          else
               @teams = Team.active.where(id: current_user.team_id)
               @projects = Project.active.where(id: @teams.select(:project_id))
               @archived = Subteam.archived.where(team_id: current_user.team_id).to_a
          end
          @projects = @projects.order(:name)
     end
end
