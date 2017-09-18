# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Stealth::IndifferentHash do
  describe "constructor" do
    it "should accept a flattened array" do
      hash = IndifferentHash[:a, 1, 'b', 2]
      expect(hash['a']).to eq 1
      expect(hash['b']).to eq 2
    end

    it "should accept an array of pairs" do
      hash = IndifferentHash[[[:a, 1], ['b', 2]]]
      expect(hash['a']).to eq 1
      expect(hash['b']).to eq 2
    end

    it 'should instantiate a new instance with .new()' do
      expect(IndifferentHash.new).to be_an_instance_of(Stealth::IndifferentHash)
    end
  end

  describe "default hash values" do
    it "should accept a default object during instantiation" do
      hash = IndifferentHash.new(0)
      expect(hash.default).to eq(0)
      expect(hash[:x]).to eq(0)
    end

    it "should accept a default block" do
      hash = IndifferentHash.new { |h, k| h[k] = [] }
      expect(hash[:x]).to eq([])
      hash[:y] << 1
      expect(hash[:y]).to eq([1])
    end
  end

  describe "merging" do
    it "should replace matching keys with the replacement in the args" do
      hash = IndifferentHash.new({ a: 1, 'b' => 2 })
      merged_hash = hash.merge({ 'b' => 3 })
      expect(merged_hash['b']).to eq 3
    end

    it "should replace symbolized keys with the string replacement in the args" do
      hash = IndifferentHash.new({ a: 1, 'b' => 2 })
      merged_hash = hash.merge({ 'a' => 3 })
      expect(merged_hash[:a]).to eq 3
    end
  end

  describe "retrieving keys" do
    let (:hash) { IndifferentHash.new({ a: 1, 'b' => 2, c: { 'd' => 3, e: { f: 4 } } }) }

    describe ".fetch()" do
      it "should find with a symbol" do
        expect(hash.fetch(:b)).to eq 2
      end

      it "should find with a string" do
        expect(hash.fetch('a')).to eq 1
      end

      it "should return a default value when the key is not found" do
        expect(hash.fetch(:x, 0)).to eq 0
      end
    end

    describe ".dig()" do
      it "should find with symbols" do
        expect(hash.dig(:c, :e, :f)).to eq 4
      end

      it "should find with strings" do
        expect(hash.dig('c', 'e', 'f')).to eq 4
      end

      it "should return nil if a key in the chain is missing" do
        expect(hash.dig(:c, :x, :f)).to be_nil
      end
    end

    describe "fetch_values()" do
      it "should find with symbols" do
        expect(hash.fetch_values(:a, :b)).to eq([1, 2])
      end

      it "should find with strings" do
        expect(hash.fetch_values('a', 'b')).to eq([1, 2])
      end

      it "should raise a key error for an unknown key" do
        expect {
          hash.fetch_values(:a, :b, :x)
        }.to raise_error(KeyError)
      end
    end

    describe "values_at()" do
      it "should find with symbols" do
        expect(hash.values_at(:a, :b)).to eq([1, 2])
      end

      it "should find with strings" do
        expect(hash.values_at('a', 'b')).to eq([1, 2])
      end
    end
  end

  describe "deleting keys" do
    let (:hash) { IndifferentHash.new({ a: 1, 'b' => 2, c: 3 }) }

    it "should delete keys with symbols" do
      hash.delete(:b)
      expect(hash).to eq({ 'a' => 1, 'c' => 3 })
    end

    it "should delete keys with strings" do
      hash.delete('a')
      expect(hash).to eq({ 'b' => 2, 'c' => 3 })
    end
  end
end
