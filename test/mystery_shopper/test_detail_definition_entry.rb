require 'common_helpers'

describe MysteryShopper::DetailDefinitionEntry do
	describe "create" do

		it "creates a detail definition entry when data type is not specified" do
			@test_detail  = MysteryShopper::DetailDefinitionEntry.create :test, { :identifier => :test_tag }
			@test_detail.must_be_instance_of MysteryShopper::DetailDefinitionEntry
		end

		it "creates a detail definition entry when data type is not found" do
			@test_detail  = MysteryShopper::DetailDefinitionEntry.create :test, { :identifier => :test_tag, :data_type => 'Integer' }
			@test_detail.must_be_instance_of MysteryShopper::DetailDefinitionEntry
		end

		it "creates a specific detail definition type when a valid data type is specified" do
			@test_detail  = MysteryShopper::DetailDefinitionEntry.create :test, { :identifier => :test_tag, :data_type => :key_value, :key => "something", :value => "something_else" }
			@test_detail.must_be_instance_of MysteryShopper::KeyValueDetailDefinitionEntry
		end
	end

	describe "initialize" do
		it "accepts identifier" do
			@test_detail = MysteryShopper::DetailDefinitionEntry.new :test, { :identifier => :test_tag }
			@test_detail.identifier.must_equal :test_tag
		end

		describe "defaults" do
			before do
				@test_detail = MysteryShopper::DetailDefinitionEntry.new :test, { :identifier => :test_tag }
			end

			it "defaults to String type" do
				@test_detail.data_type.must_equal String
			end

			it "defaults to text attribute" do
				@test_detail.attribute.must_equal nil
			end

			it "defaults to not needing to be present" do
				@test_detail.must_be_present.must_equal false
			end
		end

		it "overrides data type with valid data class" do
			@test_detail = MysteryShopper::DetailDefinitionEntry.new :test, { :identifier => :test_tag, :data_type => Float }
			@test_detail.data_type.must_equal Float
		end

		it "overrides attribute with provided name" do
			@test_detail = MysteryShopper::DetailDefinitionEntry.new :test, { :identifier => :test_tag, :attr => :src }
			@test_detail.attribute.must_equal 'src'
		end
		
		it "overrides must_be_present with provided name" do
			@test_detail = MysteryShopper::DetailDefinitionEntry.new :test, { :identifier => :test_tag, :must_be_present => true }
			@test_detail.must_be_present.must_equal true
		end
	end

	describe "get_value" do
		before do
			@doc = "<div class='product' price='3.45' available='true'>Test Product</div>"
		end

		it "gets content" do
			@test_detail =  MysteryShopper::DetailDefinitionEntry.new 'content_test', {:identifier => 'div.product'}
			@test_detail.get_value(@doc).must_equal "Test Product"
		end

		it "gets an attribute" do
			@test_detail =  MysteryShopper::DetailDefinitionEntry.new 'content_test', {:identifier => 'div.product', :attr => 'price'}
			@test_detail.get_value(@doc).must_equal "3.45"
		end

		it "returns nil if element does not exits" do
			@test_detail =  MysteryShopper::DetailDefinitionEntry.new 'content_test', {:identifier => 'div.no_product'}
			@test_detail.get_value(@doc).must_be_nil
		end

		it "transforms the value with value transform function" do
			@test_detail =  MysteryShopper::DetailDefinitionEntry.new 'content_test', {:identifier => 'div.product', :value_transform => lambda { |value| "Transformed #{value}" } }
			@test_detail.get_value(@doc).must_equal "Transformed Test Product"
		end

		describe "must be present" do
			it "throws an exception when element not present" do
				@test_detail =  MysteryShopper::DetailDefinitionEntry.new 'content_test', {:identifier => 'div.no_product', :must_be_present => true}
				
				proc {
					@test_detail.get_value(@doc)		
				}.must_raise NameError
			end

			it "throws an exception when element content is blank" do
				doc = "<div class='product' price='3.45' available='true'></div>"
				@test_detail =  MysteryShopper::DetailDefinitionEntry.new 'content_test', {:identifier => 'div.product', :must_be_present => true}
				
				proc {
					@test_detail.get_value(doc)		
				}.must_raise NameError
			end

			it "throws an exception when value not present" do
				@test_detail =  MysteryShopper::DetailDefinitionEntry.new 'content_test', {:identifier => 'div.product', :attr => 'no_attr', :must_be_present => true}
				
				proc {
					@test_detail.get_value(@doc)		
				}.must_raise NameError
			end
		end
	end
end