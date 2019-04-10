module Arel
  module Visitors
    class SQLAnywhere < Arel::Visitors::ToSql
      private

      # if turn on LIMIT keyword
      # (SET OPTION PUBLIC.reserved_keywords = 'LIMIT';)
      # default Arel::Visitors::ToSql will work correct
      # http://dcx.sap.com/index.html#sa160/en/dbadmin/reserved-keywords-option.html
      def visit_Arel_Nodes_SelectStatement(o, collector)
        # a-la https://github.com/rails/arel/blob/master/lib/arel/visitors/mysql.rb#L43
        if o.offset && !o.limit
          o.limit = Arel::Nodes::Limit.new(2147483647)
        end

        # Attempt to avoid SQLA error 'The result returned is non-deterministic':
        # http://dcx.sap.com/index.html#sa160/en/saerrors/err122.html
        if o.limit && o.orders.empty?
          o.orders = [Arel::Nodes::Ascending.new(Arel.sql("1"))]
        end

        super
      end

      def visit_Arel_Nodes_True(o, collector)
        "1=1"
      end

      def visit_Arel_Nodes_False(o, collector)
        "1=0"
      end

    end
  end
end
