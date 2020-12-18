# frozen_string_literal: true

require 'zip'
require './song'
require 'fileutils'
# Unzips music folders and rearranges them into a correct folder structure
# Designed to be used for google archied files and eMusic downloads
class MusicSorter
  attr_reader :dir, :zip_input, :zip_output, :song_output, :trash

  def initialize
    @dir = '/media/dan/HardDisk/'
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
    entry.extract(zip_output + song_name)
    # puts "Extracting #{song_name}"
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
    FileUtils.mv(file, full_path_with_file)
  rescue Errno::ENOENT
    puts "Problem moving file - #{full_path_with_file}"
  rescue StandardError
    puts "Incorrect file name - #{file}"
  end
end

ms = MusicSorter.new
# ms.unzip('takeout-20201207T151935Z-002.zip')
# ms.move('/home/dan/Coding/musicSorter/output/Andrew Bird - Armchair Apocrypha - Cataracts.mp3')
ms.unzip_all
ms.rearrange
