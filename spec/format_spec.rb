# encoding: ascii-8bit
require 'spec_helper'

describe MessagePack do
  it "nil" do
    nil.to_msgpack.should == "\xc0"
  end

  it "Boolean" do
    false.to_msgpack.should == "\xc2"
    true.to_msgpack.should == "\xc3"
  end

  describe "Integer" do
    it "positive fixnum" do
      0.to_msgpack.should == "\x00"
      1.to_msgpack.should == "\x01"
      ((1<<7)-1).to_msgpack.should == "\x7f"
      (1<<7).to_msgpack.size.should == 2
    end

    it "negative fixnum" do
      -1.to_msgpack.should == "\xff"
      (- (1<<5)).to_msgpack.should == "\xe0"
      (-((1<<5)+1)).to_msgpack.size.should == 2
    end

    it "uint 8" do
      (1<<7).to_msgpack.should == "\xcc\x80"
      ((1<<8)-1).to_msgpack.should ==  "\xcc\xff"
      (1<<8).to_msgpack.size.should == 3
    end

    it "uint 16" do
      (1<<15).to_msgpack.should == "\xcd\x80\x00"
      ((1<<16)-1).to_msgpack.should == "\xcd\xff\xff"
      (1<<16).to_msgpack.size.should == 5
    end

    it "uint 32" do
      (1<<16).to_msgpack.should == "\xce\x00\x01\x00\x00"
      ((1<<32)-1).to_msgpack.should == "\xce\xff\xff\xff\xff"
      (1<<32).to_msgpack.size.should == 9
    end

    it "uint 64" do
      (1<<32).to_msgpack.should == "\xcf\x00\x00\x00\x01\x00\x00\x00\x00"
      ((1<<64)-1).to_msgpack.should == "\xcf\xff\xff\xff\xff\xff\xff\xff\xff"
    end

    it "int 8" do
      (-((1<<5)+1)).to_msgpack.should == "\xd0\xdf"
      (-(1<<7)).to_msgpack.should == "\xd0\x80"
      (-((1<<7)+1)).to_msgpack.size.should == 3
    end

    it "int 16" do
      (-((1<<7)+1)).to_msgpack.should == "\xd1\xff\x7f"
      (-(1<<15)).to_msgpack.should == "\xd1\x80\x00"
      (-((1<<15)+1)).to_msgpack.size.should == 5
    end

    it "int 32" do
      (-((1<<15)+1)).to_msgpack.should == "\xd2\xff\xff\x7f\xff"
      (-(1<<31)).to_msgpack.should == "\xd2\x80\x00\x00\x00"
      (-((1<<31)+1)).to_msgpack.size.should == 9
    end

    it "int 64" do
      (-((1<<31)+1)).to_msgpack.should == "\xd3\xff\xff\xff\xff\x7f\xff\xff\xff"
      (-(1<<63)).to_msgpack.should == "\xd3\x80\x00\x00\x00\x00\x00\x00\x00"
    end
  end

  describe "Float" do
    it "float 64" do
      1.0.to_msgpack.should == "\xcb\x3f\xf0\x00\x00\x00\x00\x00\x00"
    end
  end

  describe "String" do
    it "fixstr" do
      ''.to_msgpack.should == "\xa0"
      'hello'.to_msgpack.should == "\xa5hello"
      ('X'*((1<<5)-1)).to_msgpack.size.should == 1+((1<<5)-1)
      ('X'*(1<<5)).to_msgpack.size.should == 1+1+(1<<5)
    end

    it "str 8" do
      ('X'*(1<<5)).to_msgpack.should == "\xd9\x20#{'X'*32}"
      ('X'*((1<<8)-1)).to_msgpack.should == "\xd9\xff#{'X'*((1<<8)-1)}"
      ('X'*(1<<8)).to_msgpack.size.should == 1+2+(1<<8)
    end

    it "str 16" do
      ('X'*(1<<8)).to_msgpack.should == "\xda\x01\x00#{'X'*256}"
      ('X'*((1<<16)-1)).to_msgpack.should == "\xda\xff\xff#{'X'*((1<<16)-1)}"
      ('X'*(1<<16)).to_msgpack.size.should == 1+4+(1<<16)
    end

    it "str 32" do
      ('X'*(1<<16)).to_msgpack.should == "\xdb\x00\x01\x00\x00#{'X'*(1<<16)}"
    end
  end

  describe "Binary" do
    skip "fixbin" do
    end

    skip "bin 8" do
    end

    skip "bin 16" do
    end

    skip "bin 32" do
    end
  end

  describe "Array" do
    it "fixarray" do
      array_n(0).to_msgpack.should == "\x90"
      array_n((1<<4)-1).to_msgpack.should == "\x9f" + ("\x2a"*((1<<4)-1))
      array_n((1<<4)).to_msgpack.size.should == 3+(1<<4)
    end

    it "array 16" do
      array_n(1<<4).to_msgpack.should == "\xdc\x00\x10" + ("\x2a"*(1<<4))
      array_n((1<<16)-1).to_msgpack.should == "\xdc\xff\xff" + ("\x2a"*((1<<16)-1))
      array_n(1<<16).to_msgpack.size.should == 1+4+(1<<16)
    end

    it "array 32" do
      array_n(1<<16).to_msgpack.should == "\xdd\x00\x01\x00\x00" + ("\x2a"*(1<<16))
    end
  end

  describe "Map" do
    it "fixmap" do
      {}.to_msgpack.should == "\x80"
      map_n(1).to_msgpack.should == "\x81" + map_n_packed(1)
      map_n((1<<4)-1).to_msgpack.should == "\x8f" + map_n_packed((1<<4)-1)
      map_n(1<<4).to_msgpack.size.should == 3+((1<<4) * 2)
    end

    it "map 16" do
      map_n(1<<4).to_msgpack.should == "\xde\x00\x10" + map_n_packed(1<<4)
      map_n((1<<16)-1).to_msgpack.should == "\xde\xff\xff" + map_n_packed((1<<16)-1)
    end

    it "map 32" do
      map_n(1<<16).to_msgpack.should == "\xdf\x00\x01\x00\x00" + map_n_packed(1<<16)
    end
  end

  describe "Extended" do
    skip "fixext 1" do
    end

    skip "fixext 2" do
    end

    skip "fixext 4" do
    end

    skip "fixext 8" do
    end

    skip "fixext 16" do
    end

    skip "ext 8" do
    end

    skip "ext 16" do
    end

    skip "ext 32" do
    end
  end


  def array_n(n)
    [42] * n
  end

  def map_n(n)
    Hash[ (0...n).map { |v|  [v, 42] } ]
  end
  def map_n_packed(n)
    packed = ''
    (0...n).each { |i|  packed += i.to_msgpack + 42.to_msgpack }
    packed
  end
end

