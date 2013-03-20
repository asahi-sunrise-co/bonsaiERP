# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class SessionsController < ApplicationController
  skip_before_filter :set_tenant, :check_authorization!

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(session_params)

    case @session.authenticate
    when true
      session[:user_id] = @session.user_id
      redirect_to dashboard_url(host: UrlTools.domain, subdomain: @session.tenant) and return
    when 'resend_registration_email'
      RegistrationMailer.send_registration(self).deliver
      redirect_to registrations_path, notice: "Le hemos reenviado el email de confirmación a #{@session.email}"
    when 'inactive_user'
      render file: 'sessions/inactive_user'
    else
      flash.now[:error] = 'El email o la contraseña que ingreso no existen.'
      render'new'
    end
  end

  def destroy
    reset_session

    redirect_to login_url(host: UrlTools.domain, subdomain: false), notice: "Ha salido correctamente."
  end


private
  def session_params
    params.require(:session).permit(:email, :password)
  end
end
