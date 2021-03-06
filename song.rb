# frozen_string_literal: true

# Song class used to extract meta data from song for rearranging
class Song
  require 'id3tag'
  attr_accessor :tag, :file_path

  def initialize(file)
    return unless file.include? '.mp3'

    @file_path = file
    mp3_file = File.open(file, 'rb')
    @tag = ID3Tag.read(mp3_file)
  end

  def title
    tag.title.gsub('/', '-').gsub("\'", "\\\'")
  end

  def album_name
    tag.album
  end

  # I believe TPE2 is the album artist.  If it does not exist use the artist
  def artist
    a = tag.get_frame(:TPE2).content
    a || tag.artist
  rescue StandardError
    # require 'pry'; binding.pry
    tag.artist
  end

  def file_name
    "#{track_num} #{title}.mp3"
  end

  def track_num
    tn = tag.track_nr
    if tn.include? '/'
      sp = tn.rindex('/') - 1
      start_point = sp || 0
      tn[0..start_point].rjust(2, '0')
    else
      tn.rjust(2, '0')
    end
  end
end

# s = Song.new("/home/dan/Coding/musicSorter/output//Lecrae/Gravity/01 The Drop (Intro).mp3")
# puts s.title
# puts s.file_name
#
# Dir.entries(path).each { |fileName|
#    next if ['.','..'].include? fileName
#    next unless fileName.include? '.mp3'
#    s = Song.new(path + fileName)
#    puts s.title
#    puts s.file_name
# }
