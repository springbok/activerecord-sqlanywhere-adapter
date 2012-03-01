# https://github.com/rsim/oracle-enhanced/blob/master/lib/active_record/connection_adapters/oracle_enhanced.rake

if defined?(drop_database) == 'method'
  def drop_database_with_sqlanywhere(config)
    if config['adapter'] == 'sqlanywhere'
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection.purge_database
    else
      drop_database_without_sqlanywhere(config)
    end
  end
  alias :drop_database_without_sqlanywhere :drop_database
  alias :drop_database :drop_database_with_sqlanywhere
end