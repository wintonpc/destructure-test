describe Destructure::SexpTransformer do

  it 'should transform object matchers with implied names' do
    result = transform(sexp { Object[x, y] })

    expect(result).to be_instance_of Obj
    expect(result.fields.size).to eql 2
    expect(result.fields[:x]).to be_instance_of Var
    expect(result.fields[:x].name).to eql :x
    expect(result.fields[:y]).to be_instance_of Var
    expect(result.fields[:y].name).to eql :y
  end

  it 'should transform object matchers with implied names' do
    result = transform(sexp { Object[x, y] })

    expect(result =~ Obj[fields: { x: Var[:name => :x], y: Var[:name => :y] }]).to be_true
  end

end