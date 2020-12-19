# frozen_string_literal: true

require 'zip'
require './song'
require 'fileutils'
# Unzips music folders and rearranges them into a correct folder structure
# Designed to be used for google archied files and eMusic downloads
class MusicSorter
  attr_reader :dir, :zip_input, :zip_output, :song_output, :trash

  def initialize
    @dir = '/mnt/Plutarch/'
    @zip_input = "#{@dir}music_zip_files/"
    @zip_output = "#{@dir}zip_output/"
    @trash = "#{@dir}trash/"
    system 'mkdir', '-p', @zip_output
    @song_output = "#{@dir}Music/"
    system 'mkdir', '-p', @song_output
  end

  def unzip_all
    files = Dir.glob("#{zip_input}/**/*\.zip")
    files.each do |file|
      puts "Unzipping #{file}"
      unzip(file)
    end
  end

  def unzip(zipfile_name)
    Zip::File.open(zipfile_name) do |zipfile|
      zipfile.each do |entry|
        next unless entry.name.include? 'mp3'

        extract(entry)
      end
    end
    FileUtils.mv(zipfile_name, trash)
  end

  def extract(entry)
    sp = entry.name.rindex('/') + 1
    start_point = sp || 0
    song_name = entry.name[start_point..-1]
    # puts "Extracting #{song_name}"
    entry.extract(zip_output + song_name)
  rescue Errno::ENOENT
    puts "Problem extracting file - #{entry.name}"
  end

  def rearrange
    files = Dir.glob("#{zip_output}/**/*\.mp3")
    files.each do |file|
      move(Song.new(file))
    end
  end

  def move(song)
    full_path = "#{song_output}#{song.artist}/#{song.album_name}"
    full_path_with_file = "#{full_path}/#{song.file_name}"
    system 'mkdir', '-p', full_path
    FileUtils.mv("\'#{song.file_path}\'", "\'#{full_path_with_file}\'")
  rescue Errno::ENOENT => e
    puts "Problem moving file - #{full_path_with_file}"
    puts e.message
    add_to_command_file(song.file_path, full_path_with_file)
  rescue ArgumentError => e
    puts e.message
  end

  def add_to_command_file(orig, dest)
    file = 'commands.txt'
    File.write(file, "mv \'#{orig}\' \'#{dest}\'\n", mode: 'a')
  end
end

ms = MusicSorter.new
# ms.unzip('takeout-20201207T151935Z-002.zip')
# ms.move('/home/dan/Coding/musicSorter/output/Andrew Bird - Armchair Apocrypha - Cataracts.mp3')
ms.unzip_all
ms.rearrange
