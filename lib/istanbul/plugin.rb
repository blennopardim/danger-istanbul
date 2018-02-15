module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  /danger-istanbul
  # @tags monday, weekends, time, rattata
  #
  class DangerIstanbul < Plugin

    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<String>]
    attr_accessor :coverage

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
		def round(number)
			number = ('%.2f' % number)
			number.to_f
		end

		def istanbul_coverage(file)
			file = File.read(file)

			results = JSON.parse(file).map do |k, v|
			  total_lines = v['s'].count.to_f
			  lines_coverage = v['s'].count{|k,v| v > 0 }.to_f
        {
          file: k,
          total_lines: total_lines,
          lines_coverage: lines_coverage,
          coverage: (lines_coverage / total_lines)
        }
			end

			total_operators = results.map{|a| a[:total_lines]}.inject(0){|sum,x| sum + x }
			num_coverage_operators = results.map{|a| a[:lines_coverage]}.inject(0){|sum,x| sum + x }
			project_coverage = num_coverage_operators / total_operators

			return {
        total_operators: total_operators,
        num_coverage_operators: num_coverage_operators,
        coverage: round(num_coverage_operators / total_operators) * 100,
        childrens: results
			}
    end
  end

end