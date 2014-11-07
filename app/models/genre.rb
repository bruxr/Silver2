class Genre < ActiveRecord::Base

  has_and_belongs_to_many :genre
  
  validates :name, presence: true
  validates :name, uniqueness: true,
                   message: "Genre has already been taken."
  
  def name=(s)
    super(s.titleize)
  end

end
