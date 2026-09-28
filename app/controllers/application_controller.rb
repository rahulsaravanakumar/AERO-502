class ApplicationController < ActionController::Base
     allow_browser versions: :modern

     helper_method :current_user, :signed_in?

     private

     def current_user
          @current_user ||= User.find_by(id: session[:user_id])
     end

     def signed_in?
          current_user.present?
     end

     def require_sign_in
          return if signed_in?

          redirect_to login_path, alert: "Please sign in to view that page."
     end

     def deny_access(message = "You are not authorized to perform that action.")
          redirect_to root_path, alert: message
     end
end
