# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks
task :rainy_day => :environment do
  RainyDayTexterJob.set.perform_now(:just_set_up)
  puts "let the texting begin"
end
