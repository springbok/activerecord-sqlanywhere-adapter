module Arel
  module Visitors
    class SQLAnywhere < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_SelectStatement(o, collector)

        if o.limit and o.limit.expr == 0
          o = o.dup
          o.limit = nil
          o.cores.map! do |core|
            core = core.dup
            core.wheres << Arel::Nodes::False.new
            core
          end
        end

        collector << "SELECT "
        # Handle DISTINCT
        using_distinct = o.cores.any? { |core|
          core.set_quantifier.class == Arel::Nodes::Distinct || core.projections.grep(/DISTINCT/)
        }
        # We don't need to use DISTINCT if there's a limit of 1
        # (avoids bug in SQLA with DISTINCT and GROUP BY)
        using_distinct = false if using_distinct && o.limit && o.limit.expr == 1
        collector << "DISTINCT " if using_distinct
        # Use TOP x for limit statements
        collector = visit(o.limit, collector) if o.limit
        # START AT x for offset
        collector = visit(Arel::Nodes::Limit.new(2147483647), collector) if !o.limit and o.offset
        # Add select
        collector_select = ActiveRecord::ConnectionAdapters::AbstractAdapter::SQLString.new
        o.cores.inject(collector_select) { |c,x|
          visit_Arel_Nodes_SelectCore(x, c)
        }
        # Remove SELECT added by arel
        select_value = collector_select.value.sub(/^SELECT?\s*/, '')
        collector << " " + select_value
        # ORDER BY
        collector = order_by_helper(o, collector)
        collector = visit(o.lock, collector) if o.lock

        collector
      end

      def order_by_helper(o, collector)
        if !o.orders.empty?
          collector << " ORDER BY #{o.orders.map { |x| visit(x, collector) }.join(', ')} "
        else
          # Attempt to avoid SQLA error 'The result returned is non-deterministic'.
          # Complete nonsense.
          collector << " ORDER BY 1" if o.limit
        end
        collector
      end

      def visit_Arel_Nodes_Offset(o, collector)
        #"START AT #{visit(o.expr, collector) + 1}"
        collector << "START AT "
        visit(o.expr+1, collector)
      end

      def visit_Arel_Nodes_Limit(o, collector)
        collector << "TOP "
        visit(o.expr, collector)
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
