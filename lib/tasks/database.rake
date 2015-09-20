require 'aws-sdk'

def parse_db_string(env=ENV['TEST_DATABASE_URL'])
  ans = {}

  # Looks like this
  # 'mysql2://user:password@host/db?sslca=path'
  db_params = env.split '@'

  ans[:user], ans[:pass] = db_params[0].split('/')[2].split(':')
  if db_params[1].include? '?'
    hostdb, ans[:sslca] = db_params[1].split '?sslca='
    ans[:host], ans[:db] = hostdb.split '/'
  else
    ans[:host], ans[:db] = db_params[1].split '/'
  end
  ans
end

def mysql(db)
  sslca = db[:sslca].nil? ? '' : "--ssl_ca=#{db[:sslca]}"
  "env MYSQL_PWD=#{db[:pass]} mysql -u #{db[:user]} -h #{db[:host]} #{db[:db]} #{sslca}"
end

def mysqldump(db)
  sslca = db[:sslca].nil? ? '' : "--ssl_ca=#{db[:sslca]}"
  "env MYSQL_PWD=#{db[:pass]} mysqldump -u #{db[:user]} -h #{db[:host]} #{db[:db]} #{sslca}"
end


namespace :db do
  task dump: :environment do
    desc 'Dumping the development database to today.sql'
    puts 'Dumping database to today.sql'
    system "#{mysqldump(parse_db_string(ENV['DEV_DATABASE_URL']))} > today.sql"
  end

  task dump_live: :environment do
    desc 'Dumping the live database to today.sql'
    puts 'Dumping live database to today.sql'
    system "#{mysqldump(parse_db_string(ENV['DATABASE_URL']))} > today.sql"
  end

  task dump_backup: :environment do
    Aws.config.update(
        {F
            region: 'eu-west-1',
            credentials: Aws::Credentials.new(ENV['S3_BACKUP_USER'], ENV['S3_BACKUP_PASS']),
        })
    s3 = Aws::S3::Client.new
    filename = "#{ENV['S3_BACKUP_FOLDER_NAME']}/#{Time.now.strftime('%Y-%m-%d')}.sql.bz2"
    puts "Downloading #{filename} to today.sql.bz2 and unzipping"
    s3.get_object({bucket: 'backup-all-companies', key: "#{filename}"}, target: 'today.sql.bz2')
    system 'bunzip2 -f today.sql.bz2'
  end

  task load: :environment do
    desc 'Loading database from today.sql'
    system "#{mysql(parse_db_string(ENV['DEV_DATABASE_URL']))} < today.sql"
  end


end
