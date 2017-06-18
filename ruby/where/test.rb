require 'minitest/autorun'

class Array
	# returns sub array of elements whose kvps match the supplied kvp(s) in h
	def where(whereClauses)
		# array to be returned
		retArr = []
		
		# iterate through array of hashes adding all elements that match all kvps in whereClauses
		each{|i|
			# start out assuming no match
			matched = false
			# tracks first whereClause match
			firstmatch = true
			
			# iterate through kvps for this element matching against whereClauses where appropriate
			i.each{|k,v| 
				# iterate through whereClauses kvps and match against like keyed element kvp
				whereClauses.each{|n,p|
					# if key values match we need to compare these
					if k == n
						# if whereClauses value is a regular expression perform Regexp match
						if p.is_a? Regexp
							if p.match(v)
								matched = true if firstmatch
							else
								matched = false
							end
						# if whereClauses value is string or integer compare directly
						else
							if p == v
								matched = true if firstmatch
							else
								matched = false
							end
						end
						
						# no longer first match (all remaining matches will only clear match flag)
						firstmatch = false
					end
				}
			}

			# if we matched all the where clauses append this element to our return array
			if matched
				retArr << i
			end
		}
		
		# return array of matched elements
		return retArr
	end
end

class WhereTest < Minitest::Test
  def setup
    @boris   = {:name => 'Boris The Blade', :quote => "Heavy is good. Heavy is reliable. If it doesn't work you can always hit them.", :title => 'Snatch', :rank => 4}
    @charles = {:name => 'Charles De Mar', :quote => 'Go that way, really fast. If something gets in your way, turn.', :title => 'Better Off Dead', :rank => 3}
    @wolf    = {:name => 'The Wolf', :quote => 'I think fast, I talk fast and I need you guys to act fast if you wanna get out of this', :title => 'Pulp Fiction', :rank => 4}
    @glen    = {:name => 'Glengarry Glen Ross', :quote => "Put. That coffee. Down. Coffee is for closers only.",  :title => "Blake", :rank => 5}

    @fixtures = [@boris, @charles, @wolf, @glen]
  end

  def test_where_with_exact_match
    assert_equal [@wolf], @fixtures.where(:name => 'The Wolf')
  end

  def test_where_with_partial_match
    assert_equal [@charles, @glen], @fixtures.where(:title => /^B.*/)
  end

  def test_where_with_mutliple_exact_results
    assert_equal [@boris, @wolf], @fixtures.where(:rank => 4)
  end

  def test_with_with_multiple_criteria
    assert_equal [@wolf], @fixtures.where(:rank => 4, :quote => /get/)
  end

  def test_with_chain_calls
    assert_equal [@charles], @fixtures.where(:quote => /if/i).where(:rank => 3)
  end
  
  def where_clause
	print [@wolf]
  end
end


print "Where test"
