describe('Test tomoauto mrcio library functions', function ()
  local mrcio
  local MRC_m0, MRC_m1, MRC_m2, MRC_m6
  local MRCS_m0, MRCS_m1, MRCS_m2, MRCS_m6

  setup(function ()
    mrcio = require('tomoauto.mrcio')
  end)

  teardown(function ()
    mrcio = nil
  end)

  before_each(function ()
    MRC_m0 = mrcio.new_MRC('./spec/test_001_mode0.mrc')
    MRC_m1 = mrcio.new_MRC('./spec/test_001_mode1.mrc')
    MRC_m2 = mrcio.new_MRC('./spec/test_001_mode2.mrc')
    MRC_m6 = mrcio.new_MRC('./spec/test_001_mode6.mrc')
    MRCS_m0 = mrcio.new_MRC('./spec/test_002_mode0.st', 10)
    MRCS_m1 = mrcio.new_MRC('./spec/test_002_mode1.st', 10)
    MRCS_m2 = mrcio.new_MRC('./spec/test_002_mode2.st', 10)
    MRCS_m6 = mrcio.new_MRC('./spec/test_002_mode6.st', 10)
  end)

  after_each(function ()
    MRC_m0, MRC_m1, MRC_m2, MRC_m6 = nil, nil, nil, nil
    MRCS_m0, MRCS_m1, MRCS_m2, MRCS_m6 = nil, nil ,nil, nil
  end)

  it('Library should properly copy a settings table.', function()
    local new_xftoxg = config.copy(xftoxg)
    assert.are.same(xftoxg, new_xftoxg)
    assert.are.equals(getmetatable(xftoxg), getmetatable(new_xftoxg))
  end)

  it('Library should make tilt-series specific settings.', function()
    local new_xftoxg = config.setup(xftoxg, MRC)
    assert.are.equal(new_xftoxg.Name, 'test_002_mode0_xftoxg.com')
    assert.are.equal(new_xftoxg.Log, 'test_002_mode0_xftoxg.log')
    assert.are.equal(new_xftoxg.InputFile.value,'test_002_mode0.prexf')
    assert.are.equal(new_xftoxg.GOutputFile.value, 'test_002_mode0.prexg')
    assert.are.equal(new_xftoxg.NumberToFit.value, 0)
  end)

  it('Should be able to reset and clear a settings table.', function()
    local new_xftoxg = config.clear(xftoxg)
    for _, key in ipairs(new_xftoxg) do
      assert.is.False(new_xftoxg[key]['use'])
    end
  end)


end)
