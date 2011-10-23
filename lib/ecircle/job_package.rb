module Ecircle
  module JobPackage
    TARGET_CONTENT_ENCODING = 'ISO-8859-1'

    def self.send_asynch_message_to_group(options)
      xml = xml_for_asynch_calls(options)
    end

    def self.xml_for_asynch_calls(options)
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.control :xmlns => 'http://webservices.ecircle-ag.com/ecm', 'request-id' => options[:request_id], 'group-id' => options[:group_id] do
        xml.message 'message-id' => 'new', 'delete' => 'false' do
          xml.tag! 'sendout-preferences' do
            xml.tag! 'object-handling', 'html-images' => 'untouched'
            xml.tag! 'email-channel', 'preferred-format' => 'email-html-multipart'
          end
          xml.tag! 'send-date' do
            xml.date Helper.date_format(options[:send_out_date])
          end
          xml.tag! 'send-report-address' do
            xml.tag! 'email-address' do
              xml.email options[:report_email]
              xml.name "Send report for newsletter for location #{options[:location_name]} sent out on #{options[:send_out_date]}"
            end
          end
          xml.tag! 'status-report', 'report-id' => 'new', 'delete' => 'false', 'user-tracking-details' => 'false',  'link-tracking-details' => 'false', 'bouncing-details' => 'false' do
            xml.tag! 'report-address' do
              xml.tag! 'email-address' do
                xml.email options[:report_email]
                xml.name "Status report for newsletter for location #{options[:location_name]} sent out on #{options[:send_out_date]}"
              end
            end
            xml.tag! 'send-date' do
              xml.date Helper.date_format(options[:send_date_for_report])
            end
          end
          xml.content 'target-content-encoding' => TARGET_CONTENT_ENCODING do
            xml.subject options[:subject], 'target-encoding' => TARGET_CONTENT_ENCODING
            xml.text options[:text], 'target-content-encoding' => TARGET_CONTENT_ENCODING
            xml.html options[:html], 'target-content-encoding' => TARGET_CONTENT_ENCODING
          end
        end
        xml.tag! 'success-report-address' do
          xml.tag! 'email-address' do
            xml.email options[:report_email]
            xml.name "Success report for newsletter for location #{options[:location_name]} sent out on #{options[:send_out_date]}"
          end
        end
        xml.tag! 'failure-report-address' do
          xml.tag! 'email-address' do
            xml.email options[:report_email]
            xml.name "Failure report for newsletter for location #{options[:location_name]} sent out on #{options[:send_out_date]}"
          end
        end
      end
      xml.target!
    end
  end
end