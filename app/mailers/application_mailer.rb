# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@bokatidindi.is'
  layout 'mailer'
end
