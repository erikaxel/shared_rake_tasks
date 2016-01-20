require 'aws-sdk'

module HelperFunctions
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
    if RUBY_PLATFORM.downcase.include?('mingw32')
      "mysql -u #{db[:user]} -p#{db[:pass]}  -h #{db[:host]} #{db[:db]} #{sslca}"
    else
      "env MYSQL_PWD=#{db[:pass]} mysql -u #{db[:user]} -h #{db[:host]} #{db[:db]} #{sslca}"
    end
  end

  def mysqldump(db)
    sslca = db[:sslca].nil? ? '' : "--ssl_ca=#{db[:sslca]}"
    if RUBY_PLATFORM.downcase.include?('mingw32')
      "mysqldump -u #{db[:user]} -p#{db[:pass]} -h #{db[:host]} #{db[:db]} #{sslca}"
    else
      "env MYSQL_PWD=#{db[:pass]} mysqldump -u #{db[:user]} -h #{db[:host]} #{db[:db]} #{sslca}"
    end
  end

  def download_s3()
    Aws.config.update(
        {
            region: 'eu-west-1',
            credentials: Aws::Credentials.new(ENV['S3_BACKUP_USER'], ENV['S3_BACKUP_PASS']),
        })
    s3 = Aws::S3::Client.new
    filename = "#{ENV['S3_BACKUP_FOLDER_NAME']}/#{Time.now.strftime('%Y-%m-%d')}.sql.bz2"
    puts "Downloading #{filename} to today.sql.bz2 and unzipping"
    s3.get_object({bucket: 'backup-all-companies', key: "#{filename}"}, target: 'today.sql.bz2')
  end

# ------------------------------------------------------------------------------------
# Permitted environments
# ------------------------------------------------------------------------------------
  def environments(arg)
    arg = arg || 'development'
    env = { 'dev' => 'DEV',
           'development' => 'DEV',
           'test' => 'TEST',
           'staging' => 'STAGING',
           'prod' => 'PROD',
           'live' => 'PROD',
           'production' => 'PROD'}[arg]
    if env.nil?
      puts "Invalid environment parameter #{arg}"
      exit
    end

    puts "Using env #{env}"
    env
  end

  def db_url(env)
    url = ENV["#{env}_DATABASE_URL"]
    if url.nil? or url.length < 1
      puts "Couldn't find environment variable: #{env}_DATABASE_URL"
      exit
    end
    url
  end

  def shell(cmd)
    puts cmd
    system cmd
  end
end
