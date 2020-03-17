# calc_percentage.sh
##### usage: calc_percentage.sh "[file_pattern]" [num_of_files] [update_seconds]
#
A simple script to track remaining files to be generated.
[file_pattern]: File pattern regex to determine which files to observe.
[num_of_files]:  Number of files  to be generated (if it is not known an approximate number can be given), and [update_seconds]: To be used to periodically check progress.

# Example
Generation of object files with make command. I assume there are 2000 files to be generated. 
##### $bash> make &
##### $bash> bash calc_percentage.sh "*.o" 2000 5
##### > 22% (440/2000)
Controls compilation progress in every 5 seconds.
