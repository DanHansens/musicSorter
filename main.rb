require 'zip'
require './song'
require 'fileutils'

class MusicSorter
  attr_reader :dir,:zip_input, :zip_output, :song_output, :trash

  def initialize
    @dir = '/media/dan/HardDisk/'
    @zip_input = @dir + 'music_zip_files/'
    @zip_output = @dir + 'zip_output/'
    @trash = @dir + 'trash/'
    system 'mkdir', '-p', @zip_output
    @song_output = @dir + 'Music/'
    system 'mkdir', '-p', @song_output
  end

  def unzip_all
    files = Dir.glob("#{zip_input}/**/*\.zip")
    files.each do |file|
      puts 'Unzipping ' + file
      unzip(file)
    end
  end

  def unzip(zipfile_name)
    Zip::File.open(zipfile_name) do |zipfile|
      zipfile.each do  |entry|
        next unless entry.name.include? 'mp3'
        begin
          sp = entry.name.rindex('/') + 1
          start_point = sp ? sp : 0
          song_name = entry.name[start_point..-1]
          entry.extract(zip_output + song_name)
          # puts "Extracting #{song_name}"
        rescue Errno::ENOENT
          puts "Problem extracting file - #{entry.name}"
        end
      end
    end
    FileUtils.mv(zipfile_name, trash)
  end

  def rearrange
    files = Dir.glob("#{zip_output}/**/*\.mp3")
    files.each do |file|
      move(file)
    end
  end

  def move(file)

    song = Song.new(file)
    begin
      full_path = song_output + song.artist + '/' + song.album_name
      full_path_with_file = full_path + '/' + song.file_name
      system 'mkdir', '-p', full_path
    rescue
      puts "Incorrect file name - #{file}"
      return
    end
    begin
      FileUtils.mv(file, full_path_with_file)
    rescue Errno::ENOENT
      puts "Problem moving file - #{full_path_with_file}"
    end
  end
end

ms = MusicSorter.new
# ms.unzip('takeout-20201207T151935Z-002.zip')
# ms.move('/home/dan/Coding/musicSorter/output/Andrew Bird - Armchair Apocrypha - Cataracts.mp3')
ms.unzip_all
ms.rearrange
