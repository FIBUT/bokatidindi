# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index
    @meta_description = 'Bókatíðindavefurinn er upplýsingasíða þar sem finna'\
    ' má hlekki við flesta titla sem vísa inn á sölusíður útgefanda.'
  end
end
