# frozen_string_literal: true

# controllers/users_controller.rb
class UsersController < ApplicationController
  post '/signup' do
    handle_exceptions do
      user = User.new(@parsed_params)
      return render_unprocessable_entity(user.errors) unless user.save

      authenticate_user = AuthenticateUser.new(@parsed_params['email'], @parsed_params['password']).call
      return render_success_response(authenticate_user) if success?(authenticate_user)

      render_unprocessable_entity(authenticate_user.errors)
    end
  end

  post '/login' do
    handle_exceptions do
      authenticate_user = AuthenticateUser.new(@parsed_params['email'], @parsed_params['password'],
                                               @parsed_params['remember_me']).call
      if success?(authenticate_user)
        return render_success_response(authenticate_user, I18n.t('login.otp_sent')) if authenticate_user[:otp].present?

        render_success_response(authenticate_user, I18n.t('login.login_successful'))
      else
        render_unprocessable_entity(authenticate_user, I18n.t('login.login_failed'))
      end
    end
  end

  post '/enable_two_factor_authentication' do
    handle_exceptions do
      find_user_by_email
      service = TwoFactorAuthenticationService.new(@user, request)
      result = service.enable_2fa_authentication
      if success?(result)
        render_success_response(result)
      else
        render_unprocessable_entity(result.type)
      end
    end
  end

  post '/verify_two_factor_authentication' do
    handle_exceptions do
      verify_service = VerifyTwoFactorAuthenticationService.new(request, @parsed_params)
      result = verify_service.verify_authentication
      if success?(result)
        render_success_response(result)
      else
        render_unprocessable_entity(result.type)
      end
    end
  end

  put '/disable_two_factor_authentication' do
    handle_exceptions do
      unless @current_user.two_factor_enabled?
        return render_success_response(@current_user, I18n.t('two_factor_authentication.already_disabled'))
      end

      if @current_user.update(two_factor_enabled: false)
        render_success_response(@current_user)
      else
        render_unprocessable_entity(@current_user.errors)
      end
    end
  end

  put '/change_password' do
    handle_exceptions do
      return render_unprocessable_entity(I18n.t('password.invalid_password')) unless correct_password?

      if @current_user.update_password(@parsed_params['new_password'])
        render_success_response(@current_user.email, I18n.t('password.change_password'))
      else
        render_unprocessable_entity(@current_user.errors)
      end
    end
  end

  private

  def find_user_by_email
    @user ||= User.find_by(email: @parsed_params['email'])
  end

  def parse_request
    @parsed_params = JSON.parse(request.body.read)
  end

  def correct_password?
    BCrypt::Password.new(@current_user.password_digest) == @parsed_params['current_password']
  end

  def success?(response)
    response[:status] == 'success'
  rescue StandardError
    false
  end
end
