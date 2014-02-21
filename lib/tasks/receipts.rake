namespace :receipts do
  task :generate => :environment do
    book = Spreadsheet.open('receipt_data.xls')
    club_sheet = book.worksheet('Club Info') # can use an index or worksheet name

    @club_name = club_sheet.rows[1][1]
    @club_contact_email = club_sheet.rows[2][1]
    @club_phone = club_sheet.rows[3][1]
    @club_address1 = club_sheet.rows[4][1]
    @club_address2 = club_sheet.rows[5][1]
    @club_address3 = club_sheet.rows[6][1]
    @club_desired_receipt_filename = club_sheet.rows[7][1]

    data_sheet = book.worksheet('Receipt Data') # can use an index or worksheet name
    count = 0
    data_sheet.each do |row|
      # assume header row
      if count == 0
        count += 1
        next
      end
      if row[0].nil? # if first cell empty
        puts "Done with this spreadsheet!"
        break
      end
      count += 1
      # require all data to be present to proceed with receipt generation
      if row[0].nil? || row[1].nil? || row[2].nil? || row[3].nil? || row[4].nil? || row[5].nil? || row[6].nil?
        puts "Some data is not present in row #{count}"
        next
      end
      @program_name = row[0]
      @participant_name = row[1]
      @payer_name = row[2]
      @payer_email = row[3]
      @date_received = row[4]
      @amount_received = row[5]
      @amount_eligible = row[6]

      puts row.join(',') # looks like it calls "to_s" on each cell's Value

      content = File.read("#{Rails.root}/app/views/receipts/cftc-receipt.html.erb")
      template = ERB.new(content) 
      # THis will generate html content 
      html_content = template.result(binding) 
      # puts html_content
      # now you have html content
      receipt_file = WickedPdf.new.pdf_from_string(html_content)

      # begin
        ReceiptMailer.receipt(@club_contact_email, @payer_email, @program_name, @participant_name, @club_desired_receipt_filename, receipt_file).deliver
      # rescue
      #   # not going to do anything right now - we'll just log errors
      #   Rails::logger.info "\n\n#{'x'*50}\n\n"
      #   Rails::logger.info "looks like there was an error with the mailer\n\n"
      # end
    end
  end
end
