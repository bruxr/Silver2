# Levenshtein algorithm for measuring the difference
# between two strings.
#
# http://rosettacode.org/wiki/Levenshtein_distance#Ruby
#
# Usage:
# distance = Levenshtein.distance('Kitten', 'Kutton')
#
module Levenshtein
 
  def self.distance(a, b)
    a, b = a.downcase, b.downcase
    costs = Array(0..b.length) # i == 0
    (1..a.length).each do |i|
      costs[0], nw = i, i - 1  # j == 0; nw is lev(i-1, j)
      (1..b.length).each do |j|
        costs[j], nw = [costs[j] + 1, costs[j-1] + 1, a[i-1] == b[j-1] ? nw : nw + 1].min, costs[j]
      end
    end
    costs[b.length]
  end
 
  # Should output:
  # distance(kitten, sitting) = 3
  # distance(saturday, sunday) = 3
  # distance(rosettacode, raisethysword) = 8
  def self.test
    %w{kitten sitting saturday sunday rosettacode raisethysword}.each_slice(2) do |a, b|
      puts "distance(#{a}, #{b}) = #{distance(a, b)}"
    end
  end
 
end