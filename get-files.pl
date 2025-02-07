#!/usr/bin/perl

  $count = 0;
  $untracked = 0;
  $directory = ".";
  @lines = split(/\n/,`cat @ARGV[0]`);
  foreach(@lines) {
    $line = $_;
    if($line =~ /Entering/) {
      @words = split(/\'/,$line);
      $directory = @words[1];
    }
    if($line =~ /modified:/) {
      $line =~ s/\s+//g;
      @words = split(/:/,$line);
      $change = @words[1];
      if($change !~ /content/) {
        print("$directory/$change\n");
      }
    }
    if($line =~ /Untracked/) {
      $untracked = 1;
      $count = 0;
    } else {
      $count++;
    }
    if(($untracked == 1) && ($count > 1)) {
       @words=split(/\s+/,$line);
       $file = @words[1];
       if($file =~ /changes/){
         $untracked = 0;
       } else {
         if($file ne "") {
           print("$directory/$file\n");
         }
       }
    }
     
  }

