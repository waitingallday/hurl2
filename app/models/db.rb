require 'fileutils'
require 'pg'

module Hurl
  class AbstractDB
    def self.encode(object)
      Zlib::Deflate.deflate Yajl::Encoder.encode(object)
    end

    def self.decode(object)
      Yajl::Parser.parse(Zlib::Inflate.inflate(object)) rescue nil
    end
  end

  class PostgresDB < AbstractDB

    def self.connection
      @@connection ||= PG::Connection::new(
        ENV.fetch("POSTGRES_HOST", "localhost"),
        ENV.fetch("POSTGRES_PORT", 5432), 
        :dbname => ENV.fetch("POSTGRES_DATABASE", "hurls"),
        :user => ENV.fetch("POSTGRES_USER", "postgres"),
        :password => ENV.fetch("POSTGRES_PASSWORD", "postgres")
      )
    end

    def self.select_query(scope)
      "SELECT content::bytea FROM %s WHERE id = $1 LIMIT 1" % connection.escape_string(scope.to_s)
    end

    def self.find(scope, id)
      connection.exec(select_query(scope), [id], 1) do |result|
        decode(result.getvalue(0, 0)) if result.num_tuples >= 1
      end
    end

    def self.insert_query(scope)
      "INSERT INTO %s VALUES ($1::varchar, $2::bytea)" % connection.escape_string(scope.to_s)
    end

    def self.save(scope, id, content)
      connection.exec(insert_query(scope), [id, {:value => encode(content), :format => 1}])
    end

    def self.count(scope)
      connection.exec("SELECT COUNT(*) FROM %s" % connection.escape_string(scope.to_s)) do |result|
        result.getvalue(0, 0)
      end
    end
  end

  class RedisDB < AbstractDB

    def self.connection
      @@uri = URI.parse(ENV.fetch("REDISTOGO_URL", "redis://127.0.0.1:6379"))
      @@connection ||= Redis.new(
        :host => @@uri.host,
        :port => @@uri.port,
        :password => @@uri.password)
    end

    def self.find(scope, id)
      decode(connection.get("hurl/#{scope}/#{id}"))
    end

    def self.save(scope, id, content)
      connection.set("hurl/#{scope}/#{id}", encode(content))
    end

    def self.count(scope)
      connection.keys("hurl/#{scope}/*").size
    end
  end

  class FileDB < AbstractDB
    DIR = File.expand_path(ENV['HURL_DB_DIR'] || "db")

    def self.find(scope, id)
      decode File.read(dir(scope, id) + id) if id && id.is_a?(String)
    rescue Errno::ENOENT
      nil
    end

    def self.save(scope, id, content)
      File.open(dir(scope, id) + id, 'w') do |f|
        f.puts encode(content)
      end

      true
    end

    def self.count(scope)
      files = Dir["#{DIR}/#{scope}/**/**"].reject do |file|
        File.directory?(file)
      end
      files.size
    end

    def self.dir(scope, id)
      path = FileUtils.mkdir_p "#{DIR}/#{scope}/#{id[0...2]}/#{id[2...4]}/"

      # In Ruby 1.9, mkdir_p always returns Array,
      # while in 1.8 it returns String when it has only one item to return.
      if path.is_a? Array
        path[0]
      else
        path
      end
    end
  end

  db_backend = ENV.fetch("DB_BACKEND", "postgres")
  DB = {
    "file" => FileDB,
    "redis" => RedisDB,
    "postgres" => PostgresDB
  }.fetch(db_backend)
end
