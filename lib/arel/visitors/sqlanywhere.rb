module Arel
  module Visitors
    class SQLAnywhere < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_SelectStatement(o, collector)
        using_distinct = o.cores.any? do |core|
          core.set_quantifier.class == Arel::Nodes::Distinct
        end

        # we don't need to use DISTINCT if there's a limit of 1
        # (avoids bug in SQLA with DISTINCT and GROUP BY)
        using_distinct = false if using_distinct && o.limit && o.limit.expr==1

        if o.limit and o.limit.expr == 0
          o = o.dup
          o.limit = nil
          o.cores.map! do |core|
            core = core.dup
            core.wheres << Arel::Nodes::False.new
            core
          end
        end

        [
          "SELECT",
          #("DISTINCT" if using_distinct),
          (visit(o.limit) if o.limit),
          (visit(Arel::Nodes::Limit.new(2147483647)) if o.limit == nil and o.offset),
          (visit(o.offset) if o.offset),
          o.cores.map { |x| visit_Arel_Nodes_SelectCore(x, collector) }.join,
          order_by_helper(o),
          (visit(o.lock) if o.lock),
        ].compact.join ' '
      end

      def order_by_helper(o)
        return "ORDER BY #{o.orders.map { |x| visit x }.join(', ')}" unless o.orders.empty?
        # Attempt to avoid SQLA error 'The result returned is non-deterministic'.
        # Complete nonsense.
        return "ORDER BY 1" if o.limit
      end

      def visit_Arel_Nodes_SelectCore(o, collector)
        super.sub(/^SELECT\s*/, '')
      end

      def visit_Arel_Nodes_Offset(o, collector)
        "START AT #{visit(o.expr) + 1}"
      end

      def visit_Arel_Nodes_Limit(o, collector)
        "TOP #{visit o.expr}"
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

Arel::Visitors::VISITORS['sqlanywhere'] = Arel::Visitors::SQLAnywhere
