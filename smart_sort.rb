#!/usr/bin/env ruby

require 'thor'
require 'digest'
require 'fileutils'
require 'find'
require 'tty-progressbar'
require 'classifier-reborn'
require_relative 'lib/deduplicator'
require_relative 'lib/intelligent_sorter'
require_relative 'lib/file_analyzer'

class SmartSort < Thor
  desc "sort PATH", "Organize files and remove duplicates"
  option :dry_run, type: :boolean, aliases: '-d', desc: "Show what would be done without making changes"
  def sort(path)
    unless Dir.exist?(path)
      puts "Error: Directory '#{path}' does not exist"
      exit 1
    end

    puts "Starting SmartSort on: #{path}"
    puts "Mode: #{options[:dry_run] ? 'DRY RUN' : 'LIVE'}\n\n"

    deduplicator = Deduplicator.new(path, dry_run: options[:dry_run])
    duplicates_info = deduplicator.process

    sorter = IntelligentSorter.new(path, dry_run: options[:dry_run])
    sorting_info = sorter.sort_files

    print_summary(duplicates_info, sorting_info)
  end

  desc "train PATH", "Train the classifier on existing folder structure"
  def train(path)
    unless Dir.exist?(path)
      puts "Error: Directory '#{path}' does not exist"
      exit 1
    end

    puts "Training classifier on: #{path}\n\n"
    sorter = IntelligentSorter.new(path)
    result = sorter.train
    
    puts "\n✓ Training complete!"
    puts "Categories learned: #{result[:categories].join(', ')}"
    puts "Files analyzed: #{result[:files_trained]}"
  end

  desc "status", "Show SmartSort version and configuration"
  def status
    puts "SmartSort v1.0.0"
    puts "Ruby version: #{RUBY_VERSION}"
    puts "\nCapabilities:"
    puts "  ✓ SHA256 deduplication"
    puts "  ✓ Bayesian text classification"
    puts "  ✓ EXIF data extraction"
    puts "  ✓ Dry-run mode"
  end

  private

  def print_summary(duplicates_info, sorting_info)
    puts "\n" + "="*60
    puts "SUMMARY"
    puts "="*60
    puts "Total files processed: #{duplicates_info[:total_files]}"
    puts "Duplicates archived: #{duplicates_info[:duplicates_count]}"
    puts "Unique files: #{duplicates_info[:unique_files]}"
    
    if sorting_info[:categories].any?
      puts "\nCategory Breakdown:"
      sorting_info[:categories].each do |category, count|
        puts "  #{category}: #{count} files"
      end
    end
    
    puts "\n#{options[:dry_run] ? '(No changes made - dry run mode)' : '✓ All operations complete'}"
  end
end

SmartSort.start(ARGV) if __FILE__ == $PROGRAM_NAME
