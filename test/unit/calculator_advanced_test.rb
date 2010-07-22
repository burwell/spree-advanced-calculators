require 'test_helper'

class AdvancedTestCalculator < Calculator::Advanced
  def self.description
    I18n.t("testing_buckets")
  end

  # as object we always get line items, as calculable we have Coupon, ShippingMethod or ShippingRate
  def compute(order_or_line_items)
    if order_or_line_items.is_a?(Array)
      total = order_or_line_items.length
    else
      total = order_or_line_items.line_items.length
    end

    get_rate(total) || self.preferred_default_amount
  end
end

class TestCalculatorAdvanced < Test::Unit::TestCase
  context Calculator::Advanced do
    should "register itself" do
      ::Calculator::Advanced.register
      ::Calculator.calculators.include?(Calculator::Advanced)
    end

    context "instance with order" do
      setup do
        @order = Factory(:order)
        @calculator =  AdvancedTestCalculator.create(
          :calculable => @order,
          :preferred_default_amount => 666
        )
      end

      should "Be advanced of course" do
        assert @calculator.advanced?
      end

      should "return preffered amount if no ranges are set" do
        assert_equal(666, @calculator.compute(@order).to_i)
      end

      should "return nil from get_rate if no rates can be found" do
        assert(!@calculator.get_rate(0))
      end

      context "and rates" do
        setup do
          (1..5).map{ |x|
            BucketRate.create(:floor => x*2, :ceiling=> x*2+2, :base_rate => x, :calculator => @calculator)
          }
          BucketRate.create(:floor => 0, :ceiling=> 2, :base_rate => 333, :calculator => @calculator)
        end

        should "find correct rates" do
          assert_equal(333, @calculator.get_rate(1).to_i)
          assert_equal(1, @calculator.get_rate(2).to_i)
          assert_equal(1, @calculator.get_rate(3).to_i)
          assert_equal(2, @calculator.get_rate(4).to_i)
          assert_equal(3, @calculator.get_rate(7).to_i)
        end

        should "calculate correctly based on order" do
          li = Factory(:line_item, :order => @order, :price => 19.99, :quantity => 1)
          assert_equal(333, @calculator.compute(@order))
        end

        should "calculate based on array of line_items" do
          li = Factory(:line_item, :order => @order, :price => 19.99, :quantity => 1)
          assert_equal(333, @calculator.compute([li]))
        end
      end

      context "and rates with increments in top bucket" do
        setup do
          (0..4).map do |x|
            BucketRate.create(:floor => x*10, :ceiling=> (x+1)*10, :base_rate => (x+1), :calculator => @calculator)
          end
          BucketRate.create(:floor => 50, :ceiling=> nil, :base_rate => 6, :value_increment => 10, :additional_rate => 1, :calculator => @calculator)
        end

        should "calculate correct rates" do
          10.times { |i|
            assert_equal(i+1, @calculator.get_rate(i*10).to_i)
          }
        end

        should "calculate correctly based on order" do
          5.times { li = Factory(:line_item, :order => @order, :price => 19.99, :quantity => 1) }
          assert_equal(1, @calculator.compute(@order).to_i)
        end

        should "calculate based on array of line_items" do
          items = []
          5.times { items << Factory(:line_item, :order => @order, :price => 19.99, :quantity => 1) }
          assert_equal(1, @calculator.compute(items).to_i)
        end
      end
    end
  end
end
