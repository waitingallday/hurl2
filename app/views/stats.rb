module Views
  class Stats < Layout
    def hurl_stats
      return [
        count(:users),
        count(:views),
        count(:hurls)
      ]
    end

    def count(thing)
      count = Hurl::DB.count(thing)

      { :stat => thing, :value => count }
    end

    def disk_stats
      [ :stat => 'db-size', :value => `du -sh db`.split(' ')[0] ]
    end
  end
end
