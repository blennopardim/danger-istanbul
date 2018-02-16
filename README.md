# danger-istanbul

A description of danger-istanbul.

## Installation

    $ gem install danger-istanbul

## Usage

    Methods and attributes from this plugin are available in
    your `Dangerfile` under the `istanbul` namespace.

   1. Load json coverage istanbul `istanbul.load('../../istanbul.json')` 
   2. Set min coverege for project `istanbul.min_coverage_project = 96` 
   3. Set min coverege for file `istanbul.min_coverage_for_file = 96` 
   4. Set base_path `istanbul.base_path = 'src'` 
   5. Run common check_coverage `istanbul.check_coverage`

## Or Manual Coverage

   Remove `istanbul.check_coverage` for `Dangefile`

   ```
    puts "Verificando o se coverage total do Projeto e superior a #{min_coverage_project}"
    if istanbul.data[:coverage] < min_coverage_project
        fail("Coverage do projeto está abaixo de #{min_coverage_project}%. Coverage atual: #{istanbul.data[:coverage]}%")
    end

    puts 'Verificando se tem testes para os arquivos modificados no pull request'
    php_files.each do |file|
        if !istanbul.test_exist?(file)
            fail "O arquvio `#{file}` está sem testes unitários"
        end
    end

    puts "Verificando coverege de cada arquivo do pull request > #{min_coverage_for_file}"
    istanbul.data[:childrens].select{|a| php_files.include?(a[:file])}.each do |file_coverage|
        if file_coverage[:coverage] < min_coverage_for_file
            fail("#{file_coverage[:file]} coverage abaixo de #{min_coverage_for_file}%. Coverage atual: #{file_coverage[:coverage]}%")
        end
    end
   ```
   
## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
