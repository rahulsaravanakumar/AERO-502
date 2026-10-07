class SessionsController < ApplicationController
     def new
          redirect_to root_path if signed_in?
     end

     def create
          user = User.find_by(email: params[:email].to_s.strip.downcase)

          if user&.authenticate(params[:password])
               reset_session
               session[:user_id] = user.id
               redirect_to root_path, notice: "Welcome back, #{user.name}."
          else
               flash.now[:alert] = "Access not authorized. Email or password is incorrect, " \
                                   "or the account has not been approved yet."
               render :new, status: :unprocessable_entity
          end
     end

     def destroy
          reset_session
          redirect_to login_path, notice: "You have signed out."
     end
end
