require 'zip'
require './song'
require 'fileutils'

class MusicSorter
  attr_reader :dir, :zip_output, :song_output

  def initialize
    @dir = '/home/dan/Coding/musicSorter/'
    @zip_output = @dir + 'output/'
    system 'mkdir', '-p', @zip_output
    @song_output = @dir + 'music/'
    system 'mkdir', '-p', @song_output
  end

  def unzip(zipfile_name = 'Lecrae.zip')
    Zip::File.open(dir + zipfile_name) do |zipfile|
      zipfile.each do  |entry|
        puts "Extracting #{entry.name}"
        entry.extract(zip_output + entry.name)
      end
    end
  end

  def rearrange
    files = Dir.glob("#{zip_output}/**/*\.mp3")
    files.each do |file|
      move(file)
    end
  end

  def move(file)
    song = Song.new(file)
    full_path = song_output + song.artist + '/' + song.album_name
    full_path_with_file = full_path + '/' + song.file_name
    system 'mkdir', '-p', full_path
    begin
      FileUtils.mv(file, full_path_with_file)
    rescue Errno::ENOENT
      puts "Problem moving file - #{full_path_with_file}"
    end
  end
end

ms = MusicSorter.new
ms.unzip('Lecrae.zip')
# ms.move('/home/dan/Coding/musicSorter/output/extracted/Lecrae/Anomaly/01 Outsiders.mp3')
ms.rearrange
