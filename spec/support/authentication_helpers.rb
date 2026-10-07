module AuthenticationHelpers
     def sign_in(user)
          post login_path, params: { email: user.email, password: "password" }
     end
end

RSpec.configure do |config|
     config.include AuthenticationHelpers, type: :request
end
