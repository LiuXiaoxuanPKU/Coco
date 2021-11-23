require 'json'
require_relative '../class_node'

class TreeSerializer
  def self.deserialize_node(node_obj)
    node = ClassNode.new(node_obj['name'])
    node.parent = node_obj['parent']
    node.constants = node_obj['constants']
    node.ast = node_obj['ast']
    node.table = node_obj['table']
    node.children = node_obj['children']
    node.constraints = node_obj['constraints']
    node
  end

  def self.deserialize_tree(filename)
    file = File.read(filename)
    data_hash = JSON.parse(file)
    nodes = []
    name_node_map = {}
    data_hash.each do |node_obj|
      node = deserialize_node(node_obj)
      name_node_map[node_obj['name']] = node
      nodes << node
    end
    root = nil
    nodes.each do |node|
      if name_node_map.key? node.parent
        node.parent = name_node_map[node.parent]
      else
        node.parent = nil
        root = node
      end
      children = []
      node.children.each do |childname|
        children << name_node_map[childname]
      end
      node.children = children
    end
    root
  end

  def dump(node); end
end
