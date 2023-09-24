task default: %w[lint test]

RuboCop::RakeTask.new(:lint) do |task|
    task.patterns = ['lib/**/*.rb', 'test/**/*.rb']
    task.fail_on_error = false
end

task :run do
    ruby 'lib/converter.rb'
end

task :test do
    ruby 'test/converter_test.rb'
end
