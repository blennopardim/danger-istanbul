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
    attr_accessor :data, :base_path, :min_coverage_project, :min_coverage_for_file

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #

    def test_exist?(file)
      return true if data[:childrens].select{|a| a[:file] == file }.size > 0
    end

    def load(file)
      file = File.read(file)

      results = JSON.parse(file).map do |k, v|
      total_lines = v['s'].count.to_f
	    lines_coverage = v['s'].count{|k,v| v > 0 }.to_f
        {
          file: resolve_path(k),
          total_lines: total_lines,
          lines_coverage: lines_coverage,
          coverage: round((lines_coverage / total_lines) * 100)
        }
      end

      total_operators = results.map{|a| a[:total_lines]}.inject(0){|sum,x| sum + x }
      num_coverage_operators = results.map{|a| a[:lines_coverage]}.inject(0){|sum,x| sum + x }
      project_coverage = num_coverage_operators / total_operators
      @data = {
        total_operators: total_operators,
        num_coverage_operators: num_coverage_operators,
        coverage: round(num_coverage_operators / total_operators) * 100,
        childrens: results
      }
    end

    def check_coverage(verbose = false)

      `export LC_ALL=C.UTF-8`
      `export LANG=en_US.UTF-8`
      `export LANGUAGE=en_US.UTF-8`
      
      php_files = git.modified_files.select{|a| a[/\.php/] && a[/src\//] && !a[/\.spec/] && !a['migrations'] }

      puts "Verificando o se coverage total do Projeto e superior a #{min_coverage_project}" if verbose
      if data[:coverage] < min_coverage_project
        fail("Coverage do projeto está abaixo de #{min_coverage_project}%. Coverage atual: #{data[:coverage]}%")
      end

      puts 'Verificando se tem testes para os arquivos modificados no pull request' if verbose
      php_files.each do |file|
          if !test_exist?(file)
              fail "O arquvio `#{file}` está sem testes unitários"
          end
      end

      puts "Verificando coverege de cada arquivo do pull request > #{min_coverage_for_file}" if verbose
      data[:childrens].select{|a| php_files.include?(a[:file])}.each do |file_coverage|
          if file_coverage[:coverage] < min_coverage_for_file
              fail("#{generate_link(file_coverage[:file])} coverage abaixo de #{min_coverage_for_file}%. Coverage atual: #{file_coverage[:coverage]}%")
          end
      end

    end

    def generate_link(file)
      branch = github.branch_for_head
      final_link = "../blob/#{branch}/#{file}"
      "<a href='#{final_link}' title='#{file}' target='_blank'>#{file.split('/').last}</a>"
    end
    
    private
    
    def round(number)
      number = ('%.2f' % number)
      number.to_f
    end

    def resolve_path(file, base_path = @base_path ? @base_path : 'src')
      index = file.split('/').find_index(base_path)
      file.split('/')[index..-1].join('/')
    end

  end
end
