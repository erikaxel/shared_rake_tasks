require File.expand_path('../../modules/helper_functions', __FILE__)
include HelperFunctions

namespace :db do
  task :dump, [:env] do |t, args|
    desc 'Dumping the database to today.sql'
    shell "#{mysqldump(parse_db_string(db_url(environments(args[:env]))))} > today.sql"
  end

  task dump_backup: :environment do
    download_s3
    shell 'bunzip2 -f today.sql.bz2'
  end

  task :load, [:env] do |t, args|
    desc 'Loading database from today.sql'
    Rake::Task['db:run_file'].invoke(args[:env], 'today.sql')
  end

  task :run_file, :env, :file do |t, args|
    desc 'Running a .sql file to a database'
    file = args[:file] || 'today.sql'
    shell "#{mysql(parse_db_string(db_url(environments(args[:env]))))} < #{file}"
  end
end
