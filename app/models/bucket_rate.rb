class BucketRate < ActiveRecord::Base
  belongs_to :calculator

  validates_presence_of :floor, :base_rate, :calculator_id

  named_scope :order_by_floor, :order => "floor"
  named_scope :for_calculator, lambda{ |calc|
    calculator_id = calc.is_a?(Calculator) ? calc.id : calc
    {:conditions => {:calculator_id => calculator_id}}
  }
  named_scope :including_value, lambda{|value|
    { :conditions => ["floor <= ? AND (ceiling > ? OR ceiling IS NULL)", value, value] }
  }

  def no_ceiling?
    ceiling.blank?
  end

  def basic_rate_only?
    additional_rate.blank? || value_increment.blank?
  end

  def unit
    calculator && calculator.unit
  end

  def validate
    if !ceiling.blank? && !floor.blank? && ceiling.to_i < floor.to_i
      errors.add(:ceiling, :higher_or_equal)
    end
  end

  def <=>(other)
    returning calculator.name <=> other.calculator.name do |sort|
      sort += floor <=> other.floor if sort.zero?
    end
  end

  def get_rate(value)
    base_rate + additional_rate_for(value)
  end

  def additional_rate_for(value)
    return 0 if basic_rate_only?
    ((value - floor) / value_increment).to_i * additional_rate
  end
end
