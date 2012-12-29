#coding:utf-8

namespace :se do

  desc "load array of events"
  
  task :loadEvent => :environment do
    filter = {}
    filter[:period.not] = '' 
    NewsEvent.published.all(filter).each do |ne|
      while ne.date.to_date < Date.today
        ne.date = case ne.period
        when 'year'
          ne.date >> 12
        when 'month'
          ne.date >> 1
        when 'week'
          ne.date + 7
        when 'day'
          ne.date + 1
        else
          ne.date
        end
      end
      ne.save
      p ne.title
    end
    p 'inc date in NewsEvent'
  end
end
