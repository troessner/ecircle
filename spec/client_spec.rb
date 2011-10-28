require 'spec_helper'

describe Ecircle::JobPackage do
  before :all do
    date = 1.hour.from_now
    @options = {
      :request_id                   => '1234',
      :group_id                     => '5678',
      :send_out_date                => date,
      :send_date_for_report         => date,
      :report_email                 => 'report@dealvertise.de',
      :location_name                => 'Berlin',
      :subject                      => 'Berlin newsletter',
      :text                         => 'Newsletter text content',
      :html                         => 'Newsletter html content'
    }

    @doc = <<xml
<control xmlns="http://webservices.ecircle-ag.com/ecm" request-id="1234" group-id="5678">
  <message message-id="new" delete="false">
    <sendout-preferences>
      <object-handling html-images="untouched"/>
      <email-channel preferred-format="email-html-multipart"/>
    </sendout-preferences>
    <send-date>
      <date>#{Ecircle::Helper.date_format(@options[:send_out_date])}</date>
    </send-date>
    <send-report-address>
      <email-address>
        <email>#{@options[:report_email]}</email>
        <name>Send report for newsletter for location #{@options[:location_name]} sent out on #{@options[:send_out_date]}</name>
      </email-address>
    </send-report-address>
    <status-report report-id="new" delete="false" user-tracking-details="false" link-tracking-details="false" bouncing-details="false">
      <report-address>
        <email-address>
          <email>#{@options[:report_email]}</email>
          <name>Status report for newsletter for location #{@options[:location_name]} sent out on #{@options[:send_out_date]}</name>
        </email-address>
      </report-address>
      <send-date>
        <date>#{Ecircle::Helper.date_format(@options[:send_date_for_report])}</date>
      </send-date>
    </status-report>
    <content target-content-encoding="ISO-8859-1">
      <subject target-encoding="ISO-8859-1">#{@options[:subject]}</subject>
      <text target-content-encoding="ISO-8859-1">#{@options[:text]}</text>
      <html target-content-encoding="ISO-8859-1">#{@options[:html]}</html>
    </content>
  </message>
  <success-report-address>
    <email-address>
      <email>#{@options[:report_email]}</email>
      <name>Success report for newsletter for location #{@options[:location_name]} sent out on #{@options[:send_out_date]}</name>
    </email-address>
  </success-report-address>
  <failure-report-address>
    <email-address>
      <email>#{@options[:report_email]}</email>
      <name>Failure report for newsletter for location #{@options[:location_name]} sent out on #{@options[:send_out_date]}</name>
    </email-address>
  </failure-report-address>
</control>
xml
  end

  describe 'xml_for_asynch_calls' do
    it 'should generate valid xml' do
      Ecircle::JobPackage.soap_body(@options).should == @doc
    end
  end
end
