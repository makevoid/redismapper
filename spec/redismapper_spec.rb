require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RedisMapper do

  it "should setup db connection" do
    RedisMapper.setup(Redis.new :db => 4).should be_a(Redis)
  end
  
  it "should delete all keys" do
    RedisMapper.delete_db
  end

  it "should create a resource" do
    class Resource < RedisMapper
      property :name
    end
    
    r = Resource.create(:name => "hola")
    r.should be_a(Resource)
    r.name.should == "hola"
  end
  
  # it "should make a sort" do
  #   class Resource < RedisMapper
  #     property :name
  #   end
  #   
  #   Resource.create(:name => "yo")
  #   Resource.create(:name => "uhm")
  #   Resource.create(:name => "argh")
  #   Resource.create(:name => "yaaa")
  #   Resource.sort
  # end
  
  it "should find by property" do
    class Resource < RedisMapper
      property :name, :index => true
    end
    
    r = Resource.create(:name => "abdullah")
    Resource.first(:name => "abdullah").id.should == r.id
  end
    
  it "should find by relation" do
    class Father < RedisMapper
      property :name
    end
    
    class Child < RedisMapper
      property :name
      property :father_id
    end
    
    f = Father.create(:name => "foo")
    c = Child.create(:name => "bar", :father_id => f.id)  
  end
  
  
  it "should get all resources selecting by an attribute" do
    class Resource < RedisMapper
      property :name
      property :description
    end
    
    RedisMapper.delete_db
    r = Resource.create(:name => "ahmed", :description => "test")
    r = Resource.create(:name => "the_terrorist", :description => "test")
    r = Resource.create(:name => "abdul", :description => "test")
    
    Resource.count.should == 3
    Resource.all(:select => :name).map{ |r| r.name }.compact.size.should == 3
    Resource.all(:select => :name).map{ |r| r.description }.compact.should == []
  end

  
end