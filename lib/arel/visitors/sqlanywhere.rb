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
        collector = maybe_visit(o.limit, collector)
        # START AT x for offset
        # Not sure what this code was meant to do??
        #collector = visit(Arel::Nodes::Limit.new(2147483647), collector) if !o.limit and o.offset
        collector = maybe_visit(o.offset, collector)
        # Add select
        collector_select = ActiveRecord::ConnectionAdapters::AbstractAdapter::SQLString.new
        o.cores.inject(collector_select) { |c,x|
          visit_Arel_Nodes_SelectCore(x, c)
        }
        # Remove SELECT and/or DISTINCT added by arel
        select_value = collector_select.value.sub(/^SELECT(\s+DISTINCT)?\s*/i, '')
        collector << " " + select_value
        # ORDER BY
        collector = order_by_helper(o, collector)
        collector = maybe_visit(o.lock, collector)

        collector
      end

      def order_by_helper(o, collector)
        if !o.orders.empty?
          collector << ORDER_BY
          len = o.orders.length - 1
          o.orders.each_with_index { |x, i|
            collector = visit(x, collector)
            collector << COMMA unless len == i
          }
        else
          # Attempt to avoid SQLA error 'The result returned is non-deterministic'.
          # Complete nonsense.
          collector << " ORDER BY 1 " if o.limit
        end
        collector
      end

      def visit_Arel_Nodes_Offset(o, collector)
        collector << " START AT "
        visit(o.expr, collector)
      end

      def visit_Arel_Nodes_Limit(o, collector)
        collector << " TOP "
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
