# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@emberobserver.com'
  layout 'mailer'
end
