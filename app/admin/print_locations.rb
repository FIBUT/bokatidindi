# frozen_string_literal: true

ActiveAdmin.register PrintLocation do
  permit_params :name, :address, :region, :latitude, :longitude, :visible

  config.filters = false

  form do |f|
    f.inputs do
      f.input :name
      f.input :address
      f.input :region, nil: false
      f.input :latitude
      f.input :longitude
      f.input :visible
    end
    f.actions
  end

  controller do
    def build_new_resource
      super.tap do |r|
        r.assign_attributes(
          region: :capital
        )
      end
    end
  end
end
