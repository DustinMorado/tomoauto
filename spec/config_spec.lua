describe('Test tomoauto config library functions', function ()
  local config
  local mrcio
  local MRC
  local xftoxg

  setup(function ()
    config = require('tomoauto.config')
    mrcio = require('tomoauto.mrcio')
    xftoxg = require('tomoauto.settings.xftoxg')
  end)

  teardown(function ()
    config = nil
    mrcio = nil
    xftoxg = nil
  end)

  before_each(function ()
    MRC = mrcio.new_MRC('./spec/test_002_mode0.st', 10)
  end)

  after_each(function ()
    MRC = nil
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
