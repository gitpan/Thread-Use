require 5.008;
use threads (); # just to force breakage if threads are not available
use ExtUtils::MakeMaker;

WriteMakefile (
 NAME		=> "Thread::Use",
 ($[ >= 5.005) ?
 (AUTHOR	=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
  ABSTRACT	=> 'use a module inside a thread only') : (),
 VERSION_FROM	=> 'lib/Thread/Use.pm',
 PREREQ_PM	=> {
                   },
);
