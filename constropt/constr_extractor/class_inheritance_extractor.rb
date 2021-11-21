require 'active_support/core_ext/string'
require 'active_support/inflector'

class ClassInheritanceExtractor < Extractor
  def visit(node, params)
    return if node.name == 'ActiveRecord::Base'

    if params.key?'table_name'
      node.table = params['table_name']
    else
      node.table = node.name.underscore.pluralize
      params['table_name'] = node.table
    end
  end
end
