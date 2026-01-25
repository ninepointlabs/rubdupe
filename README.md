# SmartSort

An intelligent CLI application that organizes files and removes duplicates using SHA256 hashing and Bayesian classification.

## Features

- **Deduplication**: SHA256 hash-based duplicate detection
- **Intelligent Sorting**: Bayesian classifier learns from existing folder structure
- **Safety First**: Dry-run mode to preview changes
- **Progress Tracking**: Visual progress bars during processing
- **Fallback Logic**: MIME type and EXIF-based sorting for non-text files

## Installation

```bash
bundle install
chmod +x smart_sort.rb
```

## Usage

### Sort Files
```bash
./smart_sort.rb sort /path/to/directory
```

### Dry Run (Preview Changes)
```bash
./smart_sort.rb sort /path/to/directory --dry-run
```

### Train Classifier
```bash
./smart_sort.rb train /path/to/organized/directory
```

### Check Status
```bash
./smart_sort.rb status
```

## How It Works

1. **Hashing Phase**: Calculates SHA256 for every file
2. **Deduplication**: Moves duplicates to `_archive/duplicates/[timestamp]`
3. **Training**: Learns from existing folder names (e.g., "Invoices", "Photos")
4. **Classification**: Categorizes unsorted files using Bayesian classification
5. **Fallback**: Uses MIME type or EXIF data for files without text content

## Architecture

- `smart_sort.rb` - Thor-based CLI interface
- `lib/deduplicator.rb` - SHA256 deduplication logic
- `lib/intelligent_sorter.rb` - Bayesian classification and sorting
- `lib/file_analyzer.rb` - Text extraction and MIME detection

## Safety Features

- Dry-run mode prevents accidental changes
- Comprehensive error handling for permission issues
- Detailed summary reports
- Automatic directory creation with `FileUtils.mkdir_p`
