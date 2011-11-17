module Ecircle
  module Helper
    extend self

    # @private
    def date_format date
      tz = date.strftime('%z')
      matcher = /(.*)(00)/.match(tz) # We need to do that because ecircle won't accept +0200, just +02:00.
      "#{date.strftime('%Y-%m-%dT%H:%M:%S')}#{matcher[1]}:#{matcher[2]}"
    end

    def build_user_xml attributes
      '<user>' + attributes.each_with_object('') do |slice, xml|
        name, value = slice.first, slice.last;
        xml << "<#{name}>#{value}</#{name}>"
      end+'</user>'
    end

    def build_group_xml attrs
      # Important note: Actually I have no idea what ecircle wants here. This works for me. Just go with the flow.
      xml = Builder::XmlMarkup.new
      xml.tag! 'group', :xmlns => 'http://webservices.ecircle-ag.com/ecm', 'group-id' => 'new', 'preferred-channel' => 'email' do
        xml.name attrs[:name]
        xml.description attrs[:description]
        xml.tag! 'email-channel' do
          xml.email attrs[:email]
        end
      end
      xml.target!.gsub('"', "'").gsub('\\', '')
    end
  end
end
