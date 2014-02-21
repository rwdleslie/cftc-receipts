class ReceiptMailer < ActionMailer::Base
  default from: "info@hyackfootball.com"
  
  def receipt(mail_from_address, mail_to_address, program_name, participant_name, desired_receipt_filename, receipt_file)
    if mail_from_address.blank?
      exit
    end

    mail_to = mail_from_address
    unless mail_to_address.blank?
      mail_to = mail_to_address
    end
    
    mail_subject = ""
    if mail_to.blank?
      mail_subject << "EMAIL NOT PROVIDED for #{participant_name}"
    end
    
    mail_from = mail_from_address
    mail_subject << "#{program_name} Tax Receipt for #{participant_name}"
    attachments["#{desired_receipt_filename}.pdf"] = receipt_file
    mail_bcc = ""
    mail_bcc = mail_from unless mail_to == mail_from
    mail(
      :to => mail_to,
      :bcc => mail_bcc,
      :from => mail_from,
      :subject => mail_subject
    )
  end
end
