module Ecircle
  module Helper
    extend self

    def date_format date
      tz = date.strftime('%z')
      matcher = /(.*)(00)/.match(tz) # We need to do that because ecircle won't accept +0200, just +02:00.
      "#{date.strftime('%Y-%m-%dT%H:%M:%S')}#{matcher[1]}:#{matcher[2]}"
    end
  end
end
