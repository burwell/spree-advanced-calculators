class Calculator::Advanced < Calculator
  has_many :bucket_rates, :foreign_key => :calculator_id, :dependent => :destroy
  preference :default_amount, :decimal, :default => 0

  before_save :set_advanced

  def self.register
    super
    Coupon.register_calculator(self)
    ShippingMethod.register_calculator(self)
    ShippingRate.register_calculator(self)
  end

  def set_advanced
    self.advanced = true
  end

  def name
    calculable.respond_to?(:name) ? calculable.name : calculable.to_s
  end

  def unit
    self.class.unit
  end

  def get_rate(value)
    BucketRate.for_calculator(self).including_value(value).first.try(:get_rate, value)
  end
end
