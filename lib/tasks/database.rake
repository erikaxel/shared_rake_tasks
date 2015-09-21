require File.expand_path('../../modules/helper_functions', __FILE__)
include HelperFunctions

namespace :db do
  task :dump, [:env] do |t, args|
    desc 'Dumping the database to today.sql'
    shell "#{mysqldump(parse_db_string(db_url(environments(args[:env]))))} > today.sql"
  end

  task dump_backup: :environment do
    download_s3
    system 'bunzip2 -f today.sql.bz2'
  end

  task :load, [:env] do |t, args|
    desc 'Loading database from today.sql'
    system "#{mysql(parse_db_string(ENV['DEV_DATABASE_URL']))} < today.sql"
  end
end
