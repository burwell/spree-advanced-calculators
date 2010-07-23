class BucketRate < ActiveRecord::Base
  belongs_to :calculator
  
  validates_presence_of :floor, :base_rate, :calculator_id
  validates_presence_of :value_increment, :additional_rate, :if => :no_ceiling?, :message => "or ceiling is required"

  named_scope :order_by_floor, :order => "floor"
  named_scope :for_calculator, lambda{ |calc|
    if calc.is_a?(Calculator)
      {:conditions => {:calculator_id => calc.id}}
    else
      {:conditions => {:calculator_id => calc.to_i}}
    end
  }
  named_scope :including_value, lambda{|value|
    { :conditions => ["floor <= ? AND (ceiling > ? OR ceiling IS NULL)", value, value] }
  }

  def no_ceiling?
    ceiling.blank?
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
    return 0 if value_increment.blank? or additional_rate.blank?
    ((value - floor) / value_increment).to_i * additional_rate
  end
end
