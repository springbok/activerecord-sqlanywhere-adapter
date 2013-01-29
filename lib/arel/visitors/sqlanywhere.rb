module Arel
  module Visitors
    class SQLAnywhere < Arel::Visitors::ToSql
      private

      def visit_Arel_Nodes_SelectStatement o
        using_distinct = o.cores.any? do |core|
          core.set_quantifier.class == Arel::Nodes::Distinct
        end
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
          ("DISTINCT" if using_distinct),
          (visit(o.limit) if o.limit),
          (visit(Arel::Nodes::Limit.new(2147483647)) if o.limit == nil and o.offset),
          (visit(o.offset) if o.offset),
          o.cores.map { |x| visit_Arel_Nodes_SelectCore x }.join,
          ("ORDER BY #{o.orders.map { |x| visit x }.join(', ')}" unless o.orders.empty?),
          (visit(o.lock) if o.lock),
        ].compact.join ' '
      end
      
      def visit_Arel_Nodes_SelectCore o
        super.sub(/^SELECT(\s+DISTINCT)?\s*/, '')
      end

      def visit_Arel_Nodes_Offset o
        "START AT #{visit(o.expr) + 1}"
      end

      def visit_Arel_Nodes_Limit o
        "TOP #{visit o.expr}"
      end
      
      def visit_Arel_Nodes_True o
        "1=1"
      end
      
      def visit_Arel_Nodes_False o
        "1=0"
      end

    end
  end
end

Arel::Visitors::VISITORS['sqlanywhere'] = Arel::Visitors::SQLAnywhere
