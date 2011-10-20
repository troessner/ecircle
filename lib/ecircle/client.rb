module Ecircle
  class Client
    TARGET_CONTENT_ENCODING = 'ISO-8859-1'

    def client
      @client ||= Savon::Client.new do
        wsdl.document =  Ecircle.configuration.wsdl
        wsdl.endpoint =  Ecircle.configuration.endpoint
        wsdl.namespace = Ecircle.configuration.namespace
      end
    end

    def request_session_id
      @response = client.request :logon do
        soap.body = {
          :user   => Ecircle.configuration.user,
          :realm  => Ecircle.configuration.realm,
          :passwd => Ecircle.configuration.password
        }
      end
      @response.body[:logon_response][:logon_return].to_s
    end

    def create_or_update_user_by_email email
      session_id = request_session_id
      @response = client.request :createOrUpdateUserByEmail do
        soap.body = {
          :session     => session_id,
          :userXml     => "<user><email>#{email}</email></user>",
          :sendMessage => 0
        }
      end
      @response.body[:create_or_update_user_by_email_response][:create_or_update_user_by_email_return].to_s
    end

    def send_parametrized_single_message_to_user user_id, message_id, names = [], values = []
      session_id = request_session_id
      @response = client.request :sendParametrizedSingleMessageToUser do
        soap.body = {
          :session           => session_id,
          :singleMessageId   => message_id,
          :userId            => user_id,
          :names             => names,
          :values            => values
        }
      end
    end

    def send_asynch_message_to_group(options)
      xml = xml_for_asynch_calls(options)
    end

    def xml_for_asynch_calls(options)
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.control :xmlns => 'http://webservices.ecircle-ag.com/ecm', 'request-id' => options[:request_id], 'group-id' => options[:group_id] do
        xml.message :message_id => 'new', 'delete' => 'false' do
          xml.tag! 'sendout-preferences' do
            xml.tag! 'object-handling', 'html-images' => 'untouched'
            xml.tag! 'email-channel', 'email-channel preferred-format' => 'email-html-multipart'
          end
          xml.tag! 'send-date' do
            xml.date options[:send_out_date]
          end
          xml.tag! 'send-report-address' do
            xml.tag! 'email-address' do
              xml.email options[:report_email]
              xml.name "Send report for newsletter for location #{options[:location_name]} sent out on #{options[:send_out_date]}"
            end
          end
          xml.tag! 'status-report', 'report-id' => 'new', 'delete' => 'false', 'since' => options[:since_date_for_status_report], 'user-tracking-details' => 'false',  'link-tracking-details' => 'false', 'bouncing-details' => 'false' do
            xml.tag! 'report-address' do
              xml.email options[:report_email]
              xml.name "Status report for newsletter for location #{options[:location_name]} sent out on #{options[:send_out_date]}"
            end
            xml.tag! 'send-date' do
              xml.date options[:send_date_for_report]
            end
          end
          xml.content 'target-content-encoding' => TARGET_CONTENT_ENCODING do
            xml.subject options[:subject], 'target-content-encoding' => TARGET_CONTENT_ENCODING
            xml.text options[:text], 'target-content-encoding' => TARGET_CONTENT_ENCODING
            xml.html options[:html], 'target-content-encoding' => TARGET_CONTENT_ENCODING
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
      end
      xml.target!
    end
  end
end
