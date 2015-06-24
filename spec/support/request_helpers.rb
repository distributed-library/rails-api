module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response_body)
    end
  end

  module LoginHelpers
    include Warden::Test::Helpers

    # for use in request specs
    def sign_in(user)
      login_as user
    end

    def token(user)
      JWT.encode({'exp' => 4.week.from_now.to_i, 'user_id' => user.id.to_s }, Rails.application.secrets.secret_key_base)
    end
  end
end
