class RedisMapper
  require 'rubygems'
  require 'redis'
  
  WARNINGS = true # set false to speed up
  
  def self.setup(db)
    @@r = db
  end
  
  
  
  def initialize(hash)
    hash.map do |key, value|
      instance_variable_set("@#{key}", value)
      self.class.send(:define_method, key){ instance_variable_get("@#{key}") }
    end
  end
  
  def self.inherited(sub)
    sub.instance_variable_set("@model", sub.name.downcase)
  end
    
  def id
    @id
  end  
    
  # internals  
    
  def self.property(name, options={})
    @properties = [] if @properties.nil?
    @properties << [name, options]
  end
  
  def self.properties
    @properties
  end
  
  def self.db
    @@r
  end
  
  def self.count
    @@r["globals:next_#{@model}_id"].to_i
  end
    
  # actions

  # GET /resources 
  def self.all(props={})
    resources = []
    max = set_all_max(props)
    (1..max).map do |obj_id|
      resources << get_resource(obj_id, props[:select])
    end
    resources
  end
  
  def self.set_all_max(props)
    if props.keys.include?(:limit)
      props[:limit]
    else
      @@r["globals:next_#{@model}_id"].to_i
    end
  end
  
  
  def self.get_resource(obj_id, select=nil)
    hash = {}
    @properties.map do |prop, opts|
      sel = select.nil? ? true : [select].flatten.include?(prop.to_sym)
      hash[prop] = @@r["#{@model}_id:#{obj_id}:#{prop}"] if sel
    end
    new(hash.merge(:id => obj_id.to_i))
  end


  def self.find(obj_id)
    get_resource obj_id
  end

  def self.first(hash={})
    # first_warning(hash) if WARNINGS
    obj_id = get_id(hash)
    get_resource obj_id
  end
  
  def self.first_warning(hash)
    raise "no index property '#{hash.keys.first}' for model '#{@model}'" unless @properties.flatten.include? hash.keys.first
  end

  def self.get_id(hash)
    hash.map do |key, value|
      @@r["#{@model}_#{key}:#{value}:id"]
    end.uniq.first
  end

  # no sort
  def self.sort()
    gets = []
    @properties.map do |prop|
      gets << "#{@model}_id:*:#{prop}"
    end
    @@r.sort("globals:next_#{@model}_id", :get => gets, 
                                          :limit => [0, 100],
                                          :order => 'asc')
  end

  # POST /resources    
  def self.create(hash)
    obj_id = @@r.incr "globals:next_#{@model}_id"
    @@r["#{@model}_id:#{obj_id}:id"]        = obj_id
    @properties.map do |prop, opts|
      value = hash[prop]
      # puts "[#{@model}_id:#{obj_id}:#{prop}] = #{hash[prop]}"
      @@r["#{@model}_id:#{obj_id}:#{prop}"] = value   unless value.nil?
      @@r["#{@model}_#{prop}:#{value}:id"]  = obj_id  if opts[:index] # CHANGES: sanitize on hash[prop]
    end
    new(hash.merge(:id => obj_id))
  end
  
  # classes
  class Resource
    # what about moving resource inside is class and make it a loadable module?? (yea like DM's)
  end
  

  # UTILS
  protected 
  def self.delete_db
    @@r.keys('*').map{ |k| @@r.del k }
  end

  
end