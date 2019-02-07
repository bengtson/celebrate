# Celebrate

The Celebrate service provides access to important dates such as birthdays
and anniversaries. There is a simple web page that shows upcoming 'celebrates'
and a full list of all celebrates.

The celebrates data is in a Filelif compendium 'Celebrate/celebrates'. The format for the file is in the Sprocks MapTable format with the following
records:

    date :: dd-mmm-yyyy or dd-mmm or mmm-yyyy or mmm
    name :: Michael Bengtson
    type :: Birthday

This will be integrated into the Tack set of services on port 4405.

## To Do

Add warning and alarm based on how close the next date is.

## Versions

Version 1.2 : Added status generation for the Tack Status System.
Verions 1.3 : Changed favicon, added version / commit as status metric.
