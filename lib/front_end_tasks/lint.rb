require 'jshintrb'

module FrontEndTasks
  class Lint

    def self.report(files)
      report = Jshintrb.report(files)
      if report.length > 0
        puts report
      else
        count = files.count
        puts "#{count} #{count == 1 ? 'file' : 'files' } lint free."
      end
    end

  end
end
