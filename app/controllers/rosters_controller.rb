class RostersController < ApplicationController
     before_action :require_sign_in
     before_action :set_subteam
     before_action :ensure_can_manage

     def update
          member = User.member.in_teams(@subteam.team_id).find_by(id: params[:user_id], access_revoked_at: nil)
          return roster_error("Choose an approved member from this class.") unless member
          member.with_lock do
               return roster_error("Remove the member's current subteam membership before adding another.") if member.subteam_id && member.subteam_id != @subteam.id

               member.update!(subteam: @subteam)
          end
          redirect_to subteam_path(@subteam), notice: "Member added to the roster."
     end

     def destroy
          member = User.member.find_by(id: params[:user_id])
          return roster_error("This member does not belong to this roster.") unless member

          member.with_lock do
               return roster_error("This member does not belong to this roster.") unless member.subteam_id == @subteam.id

               member.update!(subteam: nil)
          end
          redirect_to subteam_path(@subteam), notice: "Membership removed. Their account, assignments and hours are kept."
     end

     private

     def set_subteam
          @subteam = Subteam.find(params[:subteam_id])
     end

     def ensure_can_manage
          return if current_user.chief_engineer? || (current_user.officer? && current_user.team_id == @subteam.team_id)

          deny_access("Access denied. Only authorized leaders can manage this roster.")
     end

     def roster_error(message)
          redirect_to subteam_path(@subteam), alert: message
     end
end
