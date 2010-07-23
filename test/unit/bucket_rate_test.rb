require 'test_helper'

class TestBucketRate < Test::Unit::TestCase
  context BucketRate do
    setup do
      @bucket_rate = BucketRate.new bucket_rate_attributes
    end

    should "be creatable" do
      assert @bucket_rate.save, @bucket_rate.errors.full_messages.join(' and ')
    end

    should "check if floor is lower or equal to ceiling" do
      @bucket_rate.ceiling = 0
      assert !@bucket_rate.valid?
    end

    should "not require a ceiling" do
      @bucket_rate.ceiling = nil
      assert @bucket_rate.valid?
    end
  end

  private

  def bucket_rate_attributes(options={})
    options.reverse_merge({
      :floor         => 1,
      :ceiling       => 10,
      :base_rate     => 20,
      :calculator_id => 1
    })
  end
end
