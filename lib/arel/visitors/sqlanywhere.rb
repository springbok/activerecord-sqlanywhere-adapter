module Arel
  module Visitors
    class SQLAnywhere < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_SelectStatement(o, collector)

        # Use TOP x for limit statements
        collector_limit = ActiveRecord::ConnectionAdapters::AbstractAdapter::SQLString.new
        collector_limit = maybe_visit(o.limit, collector_limit)
        # START AT x for offset
        collector_offset = ActiveRecord::ConnectionAdapters::AbstractAdapter::SQLString.new
        collector_offset = maybe_visit(o.offset, collector_offset)
        # Add select
        collector_select = ActiveRecord::ConnectionAdapters::AbstractAdapter::SQLString.new
        o.cores.inject(collector_select) { |c,x|
          visit_Arel_Nodes_SelectCore(x, c)
        }
        # Check for Arel distinct
        using_distinct = o.cores.any? { |core|
          core.set_quantifier.class == Arel::Nodes::Distinct
        }
        # Check for distinct in SQL statement
        using_distinct = !(collector_select.value =~ /distinct/i).blank? if !using_distinct
        # Create SQL statement
        select_sql_without_order = [
          "SELECT",
          (" DISTINCT" if using_distinct),
          (collector_limit.value if !collector_limit.value.blank?),
          (visit(Arel::Nodes::Limit.new(2147483647)) if collector_limit.value.blank? && !collector_offset.value.blank?),
          (collector_offset.value if !collector_offset.value.blank?),
          (collector_select.value.sub(/^SELECT(\s+DISTINCT)?\s*/i, ' ')) # Remove SELECT and/or DISTINCT added by arel
        ].compact.join('')

        collector << select_sql_without_order
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
          collector << " ORDER BY 1" if o.limit
        end
        collector
      end

      def visit_Arel_Nodes_Offset(o, collector)
        collector << "START AT "
        visit(o.expr, collector)
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
