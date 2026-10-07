class UsersController < ApplicationController
     before_action :require_sign_in
     before_action :ensure_chief_engineer
     before_action :set_user, only: %i[edit update]

     def index
          @users = User.includes(:team).order(:name)
     end

     def edit
     end

     def update
          if @user.update(user_params)
               redirect_to users_path, notice: "#{@user.name} is now #{@user.role_with_article}."
          else
               render :edit, status: :unprocessable_entity
          end
     end

     private

     def ensure_chief_engineer
          deny_access("Only the Chief Engineer can manage people and roles.") unless current_user.chief_engineer?
     end

     def set_user
          @user = User.find(params[:id])
     end

     def user_params
          params.require(:user).permit(:role, :team_id, :subteam_id)
     end
end
