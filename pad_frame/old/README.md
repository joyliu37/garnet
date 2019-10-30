Currently we are using the hand-modified "io_file_custom" for tapeout,
see "floorplan.tcl" script:

    # Use hand-built io_file_custom,
    # not the autogenerated one, in garnet/pad_frame :(
    # read_io_file ../../../pad_frame/io_file  -no_die_size_adjust 
    read_io_file ../../../pad_frame/io_file_custom  -no_die_size_adjust 

According to comments in "io_file_custom":
  # 09/2015 steveri: I found this io_file on the arm7 machine in directory
  # /sim/ajcars/to_nikhil/updated_scripts/io_file

"io_file_custom" is similar to what happens when you run
"create_pad_frame.sh" on GarnetSOC_pad_frame.svp.new, but with some
extra offsets that were maybe put in by hand

GarnetSOC_pad_frame.svp.new was found here:
/sim/ajcars/aha-arm-soc-june-2019/components/pad_frame/GarnetSOC_pad_frame.svp