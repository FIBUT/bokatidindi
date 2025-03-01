# frozen_string_literal: true

class WelcomeController < ApplicationController
  TILE_SIZES = [16, 32, 58, 64, 76, 80, 114, 120, 128, 144, 152, 167, 180,
                192, 256, 512].freeze

  META_DESCRIPTION = 'Bókatíðindi hafa síðan 1928 veitt yfirlit yfir '\
                     'útgáfu ársins fyrir bókaunnendur. Þar má alltaf '\
                     'nálgast upplýsingar um þær bækur sem gefnar eru '\
                     'út á hverju ári.'

  def index
    expires_in 1.hour, public: true

    @website_ld_json = ld_json
    @org_ld_json     = ld_json_org

    @page_content = Page.find_by(slug: 'forsida')
    @image_format = image_format

    @editions_with_cover = Edition.joins(
      :cover_image_attachment
    ).with_attached_cover_image.current
  end

  def manifest
    expires_in 1.week, public: true

    render json: pwa_manifest
  end

  private

  def ld_json
    {
      '@context': 'https://schema.org/',
      '@id': 'https://www.bokatidindi.is/',
      '@type': ['WebSite', 'Periodical'],
      name: 'Bókatíðindi',
      about: META_DESCRIPTION,
      inLanguage: 'is',
      maintainer: ld_json_org,
      image: [
        ActionController::Base.helpers.asset_url('favicon-512.png'),
        ActionController::Base.helpers.asset_url('logotype-cropped.svg')
      ],
      url: 'https://www.bokatidindi.is/',
      potentialAction: {
        '@type': 'SearchAction',
        target: 'https://www.bokatidindi.is/baekur?search={search_term_string}',
        'query-input': 'required name=search_term_string'
      }
    }
  end

  def ld_json_org
    {
      '@type': ['Organization'],
      name: 'Félag íslenskra bókaútgefenda',
      alternateName: 'FÍBÚT',
      url: 'https://fibut.is/',
      address: {
        '@type': 'PostalAddress',
        addressLocality: 'Reykjavík',
        postalCode: '101',
        streetAddress: 'Barónsstíg 5',
        addressCountry: 'IS'
      }
    }
  end

  def pwa_manifest
    {
      id: root_url,
      scope: root_url,
      name: 'Bókatíðindi',
      description: META_DESCRIPTION,
      theme_color: '#37171f',
      background_color: '#ece8e1',
      start_url: '/',
      display: 'minimal-ui',
      orientation: 'any',
      icons: pwa_icons,
      screenshots: pwa_screenshots
    }
  end

  def pwa_icon(size)
    {
      src: ActionController::Base.helpers.asset_url("favicon-#{size}.png"),
      type: 'image/png', sizes: "#{size}x#{size}", purpose: 'maskable any'
    }
  end

  def pwa_icons
    icons = []
    TILE_SIZES.each { |t| icons << pwa_icon(t) }
    icons
  end

  def pwa_screenshots
    [
      {
        src: ActionController::Base.helpers.asset_url(
          'screenshot-desktop-fhd-landscape-half.png'
        ),
        type: 'image/png', sizes: '960x540', form_factor: 'wide',
        label: 'Yfirlit yfir íslensk skáldverk eins og sjást á tölvuskjá'
      },
      {
        src: ActionController::Base.helpers.asset_url(
          'screenshot-tablet-xga-portrait-half.png'
        ),
        type: 'image/png', sizes: '384x512', form_factor: 'narrow',
        label: 'Ævisögur og endurminningar eins og sjást á spjaldtölvu'
      }
    ]
  end
end
