class Artist < ActiveRecord::Base

  has_and_belongs_to_many :movie
  
  validates :name, presence: true
  validates :name, uniqueness: true
  
  def name=(s)
    super(s.titleize)
  end

end