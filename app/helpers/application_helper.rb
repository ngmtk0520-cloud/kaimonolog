# app/helpers/application_helper.rb
require 'zlib'

module ApplicationHelper
  def generate_colors(categories)
    palette = [
      '#FF0000', '#007BFF', '#FFCC00', '#00FF00', '#FF00FF', '#00FFFF', '#FF8C00', '#9D00FF',
      '#FF1493', '#00FA9A', '#1E90FF', '#FF4500', '#ADFF2F', '#8B00FF', '#00CED1', '#FF6347',
      '#7FFF00', '#BA55D3', '#00BFFF', '#F0E68C'
    ]
    
    categories.map do |name|
      # カテゴリー毎に色を変える。（カテゴリー毎の色も固定）
      index = Zlib.crc32(name.to_s) % palette.length
      palette[index]
    end
  end
end