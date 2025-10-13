# frozen_string_literal: true

class PrintLocationsController < ApplicationController
  def index
    @capital_locations    = PrintLocation.where(region: 1).visible
    @sudurnes_locations   = PrintLocation.where(region: 2).visible
    @vesturland_locations = PrintLocation.where(region: 3).visible
    @vestfirdir_locations = PrintLocation.where(region: 4).visible
    @nv_locations         = PrintLocation.where(region: 5).visible
    @na_locations         = PrintLocation.where(region: 6).visible
    @austurland_locations = PrintLocation.where(region: 7).visible
    @sudurland_locations  = PrintLocation.where(region: 8).visible
  end
end
