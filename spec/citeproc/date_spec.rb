require 'spec_helper'

module CiteProc
  describe Date do
    
    class Date
      describe DateParts do
        it { should_not be_nil }
        it { should be_empty }
      
        describe 'sorting' do
          it 'treats [2003] as less than [2003,1]' do
            DateParts.new(2003).should be < DateParts.new(2003,1)
          end

          it 'treats [1992,9,23] as less than [1993,8,22]' do
            DateParts.new(1992,9,23).should be < DateParts.new(1993,8,22)
          end

          it 'treats [1992,9,23] as less than [1992,10,22]' do
            DateParts.new(1992,9,23).should be < DateParts.new(1992,10,22)
          end

          it 'treats [1992,9,23] as less than [1992,9,24]' do
            DateParts.new(1992,9,23).should be < DateParts.new(1992,9,24)
          end

          it 'treats [-50] as less than [-25]' do
            DateParts.new(-50).should be < DateParts.new(-25)
          end

          it 'treats [-50] as less than [-50,12]' do
            DateParts.new(-50).should be < DateParts.new(-50,12)
          end
        end
        
        describe 'to_citeproc' do
          it 'returns an empty list by default' do
            DateParts.new.to_citeproc.should == []
          end
          
          it 'returns a list with the year if only the year is set' do
            DateParts.new(2001).to_citeproc.should == [2001]
          end

          it 'supports zero parts' do
            DateParts.new(0,0).to_citeproc.should == [0,0]
          end
        end
        
        describe '#open?' do
          it 'returns false by default' do
            DateParts.new.should_not be_open
          end
          
          it 'returns false for [1999,8,24]' do
            DateParts.new(1999, 8, 24).should_not be_open
          end
          
          it 'returns true for [0]' do
            DateParts.new(0).should be_open
          end
        end
      end
    end
    
    
    let(:ad2k) { Date.create('date-parts' => [[2000]])}
    let(:may) { Date.create('date-parts' => [[2000, 5]])}
    let(:first_of_may) { Date.create('date-parts' => [[2000, 5, 1]])}
    
    let(:bc100) { Date.create('date-parts' => [[-100]]) }
    let(:bc50) { Date.create('date-parts' => [[-50]]) }
    let(:ad50) { Date.create('date-parts' => [[50]]) }
    let(:ad100) { Date.create('date-parts' => [[100]]) }

    it { should_not be nil }
    
    it { should_not be_numeric }
    
    describe '.new' do
      
    end
    
		describe '.parse' do
			it 'returns nil by default' do
				Date.parse('').should be nil
				Date.parse(nil).should be nil
			end
			
			it 'parses date strings' do
				Date.parse('2004-10-26').year.should == 2004
			end
		end
		
    describe '.create' do
      it 'should accept parameters and return a new instance' do
        Date.create('date-parts' => [[2001, 1]]).year.should == 2001
      end
    end
    
    describe 'literal dates' do      
      it 'is not literal by default' do
        Date.new.should_not be_literal
      end
      
      it 'is literal if it contains only a literal field' do
        Date.create(:literal => 'foo').should be_literal
      end
      
      it 'is literal if it contains a literal field' do
        Date.create('date-parts' => [[2000]], :literal => 'foo').should be_literal
      end
    end
    
    describe 'uncertain dates' do
      it 'are uncertain' do
        Date.new({ 'date-parts' => [[-225]], 'circa' => '1' }).should be_uncertain
        Date.new { |d| d.parts = [[-225]]; d.uncertain! }.should be_uncertain
      end
    end
    
    describe 'sorting' do
      
      it 'dates with more date-parts will come after those with fewer parts' do
        (ad2k < may  && may < first_of_may).should be true
      end
      
      it 'negative years are sorted inversely' do
        [ad50, bc100, bc50, ad100].sort.map(&:year).should == [-100, -50, 50, 100]
      end
    end


    describe '#display' do
      it 'returns an empty string by default' do
        Date.new({}).to_s == ''
      end
    end

		describe 'b.c. and a.d.' do
			
			it 'the year 993 is a.d.' do
				Date.new(993).should be_ad
			end

			it 'the year 1000 is not a.d.' do
				Date.new(1000).should_not be_ad
			end

			it 'the year 993 is not b.c.' do
				Date.new(993).should_not be_bc
			end

			it 'the year 0 is a.d.' do
				Date.new(0).should be_ad
			end

			it 'the year 0 is not b.c.' do
				Date.new(0).should_not be_bc
			end

			it 'the year -33 is not a.d.' do
				Date.new(-33).should_not be_ad
			end

			it 'the year -33 is b.c.' do
				Date.new(-33).should be_bc
			end
			
			it 'today is not a.d.' do
				Date.today.should_not be_ad
			end
			
			it 'today is not b.c.' do
				Date.today.should_not be_bc
			end

			it 'the year 2000 is not a.d.' do
				ad2k.should_not be_ad
			end
			
		end
		
		describe '#empty?' do
		  it 'returns false by default' do
		    Date.new.should_not be_empty
		  end
		  
		  it 'returns true when it contains no date parts' do
		    Date.new({}).should be_empty
		  end
		  
		  it 'returns false for literal dates' do
		    Date.new(:literal => 'foo').should_not be_empty
		  end

		  it 'returns false for seasons' do
		    Date.new(:season => 'Summer').should_not be_empty
		  end
		end
		
    describe '#to_json' do    
      it 'supports simple parts' do
        Date.new(%w{2000 1 15}).to_json.should == '{"date-parts":[[2000,1,15]]}'
      end

      it 'supports string parts' do
        Date.new(['2000', '1', '15']).to_json.should == '{"date-parts":[[2000,1,15]]}'
      end

      it 'supports integer parts' do
        Date.new([2000, 1, 15]).to_json.should == '{"date-parts":[[2000,1,15]]}'
      end
        
      it 'supports mixed parts' do
        Date.new(['2000', 1, '15']).to_json.should == '{"date-parts":[[2000,1,15]]}'
      end

      it 'supports negative years' do
        Date.new(-200).to_json.should == '{"date-parts":[[-200]]}'
      end

      it 'treats seasons as a strings' do
        Date.create({:season => '1', 'date-parts' => [[1950]]}).to_json.should == '{"date-parts":[[1950]],"season":"1"}'
      end
      
      it 'supports seasons' do
        Date.create({:season => 'Trinity', 'date-parts' => [[1975]]}).to_json.should == '{"date-parts":[[1975]],"season":"Trinity"}'
      end

      it 'supports string literals' do
        Date.new(:literal => '13th century').to_json.should == '{"literal":"13th century"}'
      end

      it 'supports raw strings' do
        Date.new(:raw => '23 May 1955').to_json.should == '{"date-parts":[[1955,5,23]]}'
      end

      it 'supports closed ranges' do
        Date.new([[2000,11],[2000,12]]).to_json.should == '{"date-parts":[[2000,11],[2000,12]]}'
      end
      
      it 'supports open ranges' do
        Date.new([[2000,11],[0,0]]).to_json.should == '{"date-parts":[[2000,11],[0,0]]}'
      end
    end

  end
end
